// Self-checks for the page's colour maths (run: node check-derive.mjs).
import { readFileSync } from 'node:fs';
const src = readFileSync('script.js', 'utf8').split('// --- palette editor')[0]
  .replace('__DATA__', readFileSync('tetra.json', 'utf8'));
const { DATA, derive, toLch, fromLch, maxChroma, oklab, toHsl, fromHsl, bestStart, toOkhsl, fromOkhsl, okhslLinear, SOURCE_ROLES, SOURCE_ROLE_OFFSETS, ROLE_DEFAULTS, applyOffset, hueDiff, rgbOf, applyRules, NEUTRAL_KEYS, ruleHue, placeOnGround, groundOf, contrast, POSITIONED, DISTANCED, HUES, eff, rules } =
  new Function('localStorage', src + '; return { DATA, derive, toLch, fromLch, maxChroma, oklab, toHsl, fromHsl, bestStart, toOkhsl, fromOkhsl, okhslLinear, SOURCE_ROLES, SOURCE_ROLE_OFFSETS, ROLE_DEFAULTS, applyOffset, hueDiff, rgbOf, applyRules, NEUTRAL_KEYS, ruleHue, placeOnGround, groundOf, contrast, POSITIONED, DISTANCED, HUES, eff, rules };')(undefined);
const fail = [];

// derive() reproduces the generator's status, Paseo and wallpaper values.
for (const v of Object.keys(DATA)) {
  const d = derive(v, DATA[v].colors);
  for (const k of ['status', 'paseo', 'wall'])
    if (JSON.stringify(d[k]) !== JSON.stringify(DATA[v][k])) fail.push(`derive ${v} ${k}`);
}
// Every palette colour survives a round trip through OKLCH and HSL.
for (const v of Object.keys(DATA)) for (const [k, h] of Object.entries(DATA[v].colors)) {
  const [L, C, H] = toLch(h), [l, s, hh] = toHsl(h);
  if (fromLch(L, C, Number.isNaN(H) ? 0 : H) !== h) fail.push(`oklch ${v} ${k}`);
  if (fromHsl(l, s, Number.isNaN(hh) ? 0 : hh) !== h) fail.push(`hsl ${v} ${k}`);
  const [ol, os, oh] = toOkhsl(h);
  if (fromOkhsl(ol, os, Number.isNaN(oh) ? 0 : oh) !== h) fail.push(`okhsl ${v} ${k}`);
}
// Out-of-gamut picks keep lightness and hue.
const far = fromLch(0.7, 0.33, 145), [L2, a2, b2] = oklab(far), H2 = (Math.atan2(b2, a2) * 180 / Math.PI + 360) % 360;
if (!(Math.abs(L2 - 0.7) < 0.01 && Math.abs(H2 - 145) < 1.5 && maxChroma(0.7, 145) < 0.33)) fail.push('gamut map');
// bestStart finds the rotation of hues already 60° apart, including across 0°.
for (const s0 of [0, 18.6, 350]) {
  const got = bestStart([0, 1, 2, 3, 4, 5].map(i => (s0 + 60 * i) % 360));
  if (Math.abs(((got - s0 + 540) % 360) - 180) > 1e-6) fail.push(`bestStart ${s0} -> ${got}`);
}
// OKHSL: pure red is about okhsl(29.2 100% 56.8%), and 100% saturation sits on the
// sRGB edge (some channel at 0 or 1) at any hue and lightness.
const [rl, rs, rh] = toOkhsl('#ff0000');
if (!(Math.abs(rh - 29.2) < 0.3 && Math.abs(rs - 1) < 0.01 && Math.abs(rl - 0.568) < 0.005)) fail.push(`okhsl red ${rh} ${rs} ${rl}`);
for (const [l, h] of [[0.3, 20], [0.5, 140], [0.7, 260], [0.9, 100], [0.2, 300]]) {
  const lin = okhslLinear(l, 1, h), edge = Math.min(...lin.map(x => Math.min(Math.abs(x), Math.abs(1 - x))));
  if (edge > 0.01 || lin.some(x => x < -0.01 || x > 1.01)) fail.push(`okhsl edge ${l} ${h} ${lin}`);
}
// Each inherited role offset rebuilds the source role colour from the source base colour.
for (const [v, rs] of Object.entries(SOURCE_ROLES)) for (const [r, [hex, baseHex]] of Object.entries(rs)) {
  const got = applyOffset(baseHex, SOURCE_ROLE_OFFSETS[v][r]), d = Math.max(...rgbOf(got).map((x, i) => Math.abs(x - rgbOf(hex)[i])));
  if (d > 1) fail.push(`role ${v} ${r} ${got} vs ${hex}`);
}
// Rules: neutral shades keep OKLab lightness with no chroma; the hue layout puts
// brown one slot after red, yellow and orange either side of it, and keeps OKHSL l and s.
for (const v of Object.keys(DATA)) {
  const r = { neutral: true, hues: true, mutedFromSel: true, selFromAccent: true, red: 11, split: 10, selPct: 30 }, gen = DATA[v].colors, c = applyRules(r, { ...gen }, DATA[v].mode);
  {
    const [sl, ss, sh] = toOkhsl(c.selection), [al, , ah] = toOkhsl(c.accent), [, s0] = toOkhsl(gen.selection);
    const want = DATA[v].mode === 'light' ? 1 - 0.3 * (1 - al) : 0.3 * al;
    // Near-greys lose hue precision to 8-bit rounding (a pale Light selection moves ~7°), so only check hue with real chroma.
    const [, sa, sb] = oklab(c.selection), hueOk = Math.hypot(sa, sb) < 0.03 || Math.abs(((sh - ah - 180 + 540) % 360) - 180) <= 3;
    if (Math.abs(sl - want) > 0.004 || !hueOk || Math.abs(ss - s0) > 0.05) fail.push(`selection ${v} ${c.selection} l ${sl}/${want} h ${sh}/${ah + 180} s ${ss}/${s0}`);
  }
  {
    const [ml, ms, mh] = toOkhsl(c.muted), [l0] = toOkhsl(gen.muted), [, ss, sh] = toOkhsl(c.selection);
    if (Math.abs(ml - l0) > 0.004 || Math.abs(ms - ss) > 0.02 || Math.abs(((mh - sh + 540) % 360) - 180) > 2) fail.push(`muted ${v} ${c.muted} l ${ml}/${l0} s ${ms}/${ss} h ${mh}/${sh}`);
  }
  for (const k of NEUTRAL_KEYS) {
    const [L, a, b] = oklab(c[k]), [L0] = oklab(gen[k]);
    if (Math.abs(L - L0) > 0.003 || Math.hypot(a, b) > 1e-3) fail.push(`neutral ${v} ${k}`);
  }
  const want = { red: 11, brown: 71, yellow: 81, bright_yellow: 81, orange: 61, green: 131, cyan: 191, blue: 251, magenta: 311 };
  for (const [k, h] of Object.entries(want)) {
    const [l, s, hh] = toOkhsl(c[k]), [l0, s0] = toOkhsl(gen[k]);
    if (ruleHue(r, k) !== h || Math.abs(((hh - h + 540) % 360) - 180) > 1 ||   // 8-bit rounding moves hue most for dark, fully saturated colours
      Math.abs(l - l0) > 0.004 || Math.abs(s - s0) > 0.01) fail.push(`hues ${v} ${k} ${hh} ${l}/${l0} ${s}/${s0}`);
  }
}
// Tetra's own role offsets reproduce the Dark colours they were measured from.
{
  const r = { neutral: true, hues: true, mutedFromSel: true, selFromAccent: true, red: 11, split: 20, selPct: 30 };
  const c = applyRules(r, { ...DATA.dark.colors, accent: '#e0b838' }, 'dark');
  if (applyOffset(c.bright_magenta, ROLE_DEFAULTS.dark.vcs_modified) !== '#c0a3fa') fail.push('tetra vcs_modified offset');
  {   // operator, error and vcs_removed were picked on Dark with red at 12°
    const c12 = applyRules({ ...r, red: 12 }, { ...DATA.dark.colors }, 'dark');
    if (applyOffset(c12.orange, ROLE_DEFAULTS.dark.operator) !== '#ee9673') fail.push('tetra operator offset');
    if (applyOffset(c12.bright_red, ROLE_DEFAULTS.dark.error) !== '#e74555') fail.push('tetra error offset');
    if (applyOffset(c12.bright_red, ROLE_DEFAULTS.dark.vcs_removed) !== '#fd6178') fail.push('tetra vcs_removed offset');
  }
  // special keeps accent's OKHSL hue and lightness at half its saturation, in every variant
  for (const v of Object.keys(DATA)) {
    const accent = DATA[v].colors.accent, [l, s, h] = toOkhsl(applyOffset(accent, ROLE_DEFAULTS[v].special)), [l0, s0, h0] = toOkhsl(accent);
    if (Math.abs(l - l0) > 0.004 || Math.abs(s - s0 / 2) > 0.01 || Math.abs(hueDiff(h, h0)) > 1) fail.push(`special ${v} ${l}/${l0} ${s}/${s0 / 2} ${h}/${h0}`);
  }
}
// The system: Dark placed on its own ground with its own accent is unchanged; on Light's
// ground the sunk backgrounds go below the background, every normal colour reaches 4.5:1,
// and hue and saturation stay Dark's.
{
  const r = { neutral: true, hues: true, mutedFromSel: true, selFromAccent: true, red: 11, split: 20, selPct: 30 };
  const src = applyRules(r, { ...DATA.dark.colors }, 'dark');
  const same = placeOnGround(src, groundOf(src), src.accent);
  for (const k of Object.keys(src)) if (same[k] !== src[k]) fail.push(`system identity ${k} ${src[k]} -> ${same[k]}`);
  const light = placeOnGround(src, groundOf(DATA.light.colors), src.accent, 0.65);
  // hues ignore the foreground: a darker Light foreground leaves them where they were
  const darkerFg = placeOnGround(src, { ...groundOf(DATA.light.colors), fg: 0.25 }, src.accent, 0.65);
  for (const k of DISTANCED) if (darkerFg[k] !== light[k]) fail.push(`hue follows foreground ${k}`);
  for (const k of ['dark_background', 'darker_background']) if (!(toOkhsl(light[k])[0] < toOkhsl(light.background)[0])) fail.push(`light sunk ${k}`);
  for (const k of HUES) if (contrast(light[k], light.background) < 4.5) fail.push(`light normal ${k} ${contrast(light[k], light.background)}`);
  for (const k of DISTANCED.filter(k => k.startsWith('bright_'))) {
    const [, s0, h0] = toOkhsl(src[k]), [, s1, h1] = toOkhsl(light[k]);
    if (Math.abs(s1 - s0) > 0.03 || Math.abs(((h1 - h0 + 540) % 360) - 180) > 2) fail.push(`light keeps ${k} hue/sat ${h0}/${h1} ${s0}/${s1}`);
  }
}
// The generator's themes are the page's palettes with every rule and the system on
// (DATA[v].theme comes from theme_palette() and roles() via extract.py).
Object.assign(rules, { neutral: true, hues: true, selFromAccent: true, mutedFromSel: true, system: true });
for (const v of Object.keys(DATA)) {
  const page = eff(v);
  for (const [k, hex] of Object.entries(DATA[v].theme)) if (page[k] !== hex) fail.push(`generator ${v} ${k} ${hex} vs page ${page[k]}`);
}
console.log(fail.length ? 'FAIL\n' + fail.join('\n') : 'all colour checks pass');
process.exitCode = fail.length ? 1 : 0;
