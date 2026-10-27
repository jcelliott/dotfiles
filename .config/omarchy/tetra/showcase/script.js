const DATA = __DATA__;

const TITLES = { dark: 'Tetra Dark', mirage: 'Tetra Mirage', light: 'Tetra Light' };
const VARIANTS = Object.keys(DATA);
const KEYS = Object.keys(DATA.dark.colors);
const HUES = ['red', 'yellow', 'green', 'cyan', 'blue', 'magenta'];
const SLOTS = [
  ['background', 'black'], ['red', 'red'], ['green', 'green'], ['yellow', 'yellow'], ['blue', 'blue'], ['magenta', 'magenta'], ['cyan', 'cyan'], ['foreground', 'white'],
  ['muted', 'bright black'], ['bright_red', 'bright red'], ['bright_green', 'bright green'], ['bright_yellow', 'bright yellow'], ['bright_blue', 'bright blue'], ['bright_magenta', 'bright magenta'], ['bright_cyan', 'bright cyan'], ['bright_foreground', 'bright white'],
  ['orange', 'orange'], ['brown', 'brown'], ['lighter_background', 'inactive pane'], ['selection', 'selection'], ['dark_foreground', 'dark fg'], ['light_foreground', 'light fg'], ['status', 'tmux status'],
];
const HEX = /^#[0-9a-f]{6}$/;

// --- colour maths, ported from the generator so derived colours follow edits ---
const rgbOf = h => [1, 3, 5].map(i => parseInt(h.slice(i, i + 2), 16));
const s2l = c => (c /= 255) <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4;
const l2s = c => { c = Math.min(1, Math.max(0, c)); const v = c <= 0.0031308 ? 12.92 * c : 1.055 * c ** (1 / 2.4) - 0.055; return Math.round(Math.min(1, Math.max(0, v)) * 255); };
const toHex = cs => '#' + cs.map(x => x.toString(16).padStart(2, '0')).join('');
function oklab(h) {
  const [r, g, b] = rgbOf(h).map(s2l);
  const l = Math.cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b);
  const m = Math.cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b);
  const s = Math.cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b);
  return [0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
          1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
          0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s];
}
function labToLinear(L, a, b) {
  const l = (L + 0.3963377774 * a + 0.2158037573 * b) ** 3;
  const m = (L - 0.1055613458 * a - 0.0638541728 * b) ** 3;
  const s = (L - 0.0894841775 * a - 1.2914855480 * b) ** 3;
  return [4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
          -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
          -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s];
}
const fromOklab = (L, a, b) => toHex(labToLinear(L, a, b).map(l2s));
const lighten = (h, d) => { const [L, a, b] = oklab(h); return fromOklab(L + d, a, b); };
const mixOklab = (x, y, t) => { const p = oklab(x), q = oklab(y); return fromOklab(...p.map((v, i) => v * (1 - t) + q[i] * t)); };
function lum(h) { const c = rgbOf(h).map(s2l); return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]; }
function contrast(a, b) { const [x, y] = [lum(a), lum(b)].sort((p, q) => p - q); return (y + 0.05) / (x + 0.05); }

// What the generator computes from colors.toml values: the tmux status shade,
// Paseo's colours and the wallpaper gradient.
function derive(v, c, mode = DATA[v].mode) {
  const fg = rgbOf(c.foreground);
  const status = toHex(rgbOf(c.lighter_background).map((x, i) => Math.floor(x * 0.97 + fg[i] * 0.03 + 0.5)));
  const floor = h => { for (let i = 0; mode === 'light' && i < 200 && contrast(h, c.background) < 4.5; i++) h = lighten(h, -0.005); return h; };
  const paseo = {
    background: c.background, foreground: c.foreground, raised: c.lighter_background,
    control: mixOklab(c.lighter_background, c.muted, 0.17), border: mixOklab(c.lighter_background, c.muted, 0.62),
    accent: floor(c.accent), mutedForeground: floor(mixOklab(c.foreground, c.muted, 0.5)), ring: c.muted,
  };
  const wall = mode === 'light' ? ['#ffffff', c.dark_background] : [lighten(c.background, 0.06), c.background];
  return { status, paseo, wall };
}


// --- colour spaces for the picker. Each maps a hex to (lightness, chroma or
// saturation, hue) and back; the wheel puts hue around and chroma outward. ---
const CMAX = 0.33;   // a little past sRGB's most chromatic colour (blue, about 0.32)
const RAD = Math.PI / 180;
function toLch(h) { const [L, a, b] = oklab(h), C = Math.hypot(a, b); return [L, C, C < 2e-4 ? NaN : (Math.atan2(b, a) / RAD + 360) % 360]; }
const linOk = lin => lin.every(v => v >= -1e-4 && v <= 1 + 1e-4);
const inGamut = (L, C, H) => linOk(labToLinear(L, C * Math.cos(H * RAD), C * Math.sin(H * RAD)));
function maxChroma(L, H) {
  let lo = 0, hi = CMAX;
  if (inGamut(L, hi, H)) return hi;
  for (let i = 0; i < 18; i++) { const m = (lo + hi) / 2; inGamut(L, m, H) ? lo = m : hi = m; }
  return lo;
}
// Out-of-gamut picks keep their lightness and hue and lose chroma, rather than
// having each RGB channel clipped (which shifts the hue).
const fromLch = (L, C, H) => { const c = Math.min(C, maxChroma(L, H)); return fromOklab(L, c * Math.cos(H * RAD), c * Math.sin(H * RAD)); };

function toHsl(hex) {
  const [r, g, b] = rgbOf(hex).map(x => x / 255), max = Math.max(r, g, b), min = Math.min(r, g, b), l = (max + min) / 2, d = max - min;
  if (d < 1e-9) return [l, 0, NaN];
  const h = max === r ? ((g - b) / d + 6) % 6 : max === g ? (b - r) / d + 2 : (r - g) / d + 4;
  return [l, d / (1 - Math.abs(2 * l - 1)), h * 60];
}
function hslRgb(l, s, h) {
  const a = s * Math.min(l, 1 - l), k = n => (n + h / 30) % 12;
  return [0, 8, 4].map(n => l - a * Math.max(-1, Math.min(k(n) - 3, 9 - k(n), 1)));
}
const fromHsl = (l, s, h) => toHex(hslRgb(l, s, h).map(x => Math.round(x * 255)));

// OKHSL (Björn Ottosson, "Okhsv and Okhsl", 2021): OKLab's lightness through a
// toe so it matches CIE L*, and saturation scaled so 100% is the sRGB edge at
// every hue and lightness. Hue is OKLCH's hue. Ported from his reference code.
function maxSaturation(a, b) {
  let k0, k1, k2, k3, k4, wl, wm, ws;
  if (-1.88170328 * a - 0.80936493 * b > 1) { [k0, k1, k2, k3, k4, wl, wm, ws] = [1.19086277, 1.76576728, 0.59662641, 0.75515197, 0.56771245, 4.0767416621, -3.3077115913, 0.2309699292]; }
  else if (1.81444104 * a - 1.19445276 * b > 1) { [k0, k1, k2, k3, k4, wl, wm, ws] = [0.73956515, -0.45954404, 0.08285427, 0.12541070, 0.14503204, -1.2684380046, 2.6097574011, -0.3413193965]; }
  else { [k0, k1, k2, k3, k4, wl, wm, ws] = [1.35733652, -0.00915799, -1.15130210, -0.50559606, 0.00692167, -0.0041960863, -0.7034186147, 1.7076147010]; }
  let S = k0 + k1 * a + k2 * b + k3 * a * a + k4 * a * b;
  const kl = 0.3963377774 * a + 0.2158037573 * b, km = -0.1055613458 * a - 0.0638541728 * b, ks = -0.0894841775 * a - 1.2914855480 * b;
  const l_ = 1 + S * kl, m_ = 1 + S * km, s_ = 1 + S * ks;
  const f = wl * l_ ** 3 + wm * m_ ** 3 + ws * s_ ** 3;
  const f1 = wl * 3 * kl * l_ * l_ + wm * 3 * km * m_ * m_ + ws * 3 * ks * s_ * s_;
  const f2 = wl * 6 * kl * kl * l_ + wm * 6 * km * km * m_ + ws * 6 * ks * ks * s_;
  return S - f * f1 / (f1 * f1 - 0.5 * f * f2);   // one Halley step
}
function findCusp(a, b) {
  const S = maxSaturation(a, b), rgb = labToLinear(1, S * a, S * b), L = Math.cbrt(1 / Math.max(...rgb));
  return [L, L * S];
}
function gamutIntersection(a, b, L1, C1, L0, cusp) {
  if ((L1 - L0) * cusp[1] - (cusp[0] - L0) * C1 <= 0) return cusp[1] * L0 / (C1 * cusp[0] + cusp[1] * (L0 - L1));
  let t = cusp[1] * (L0 - 1) / (C1 * (cusp[0] - 1) + cusp[1] * (L0 - L1));
  const dL = L1 - L0, dC = C1;
  const kl = 0.3963377774 * a + 0.2158037573 * b, km = -0.1055613458 * a - 0.0638541728 * b, ks = -0.0894841775 * a - 1.2914855480 * b;
  const ldt = dL + dC * kl, mdt = dL + dC * km, sdt = dL + dC * ks;
  const L = L0 * (1 - t) + t * L1, C = t * C1;
  const l_ = L + C * kl, m_ = L + C * km, s_ = L + C * ks;
  const l = l_ ** 3, m = m_ ** 3, s = s_ ** 3;
  const l1 = 3 * ldt * l_ * l_, m1 = 3 * mdt * m_ * m_, s1 = 3 * sdt * s_ * s_;
  const l2 = 6 * ldt * ldt * l_, m2 = 6 * mdt * mdt * m_, s2 = 6 * sdt * sdt * s_;
  const step = ([w0, w1, w2]) => {
    const r = w0 * l + w1 * m + w2 * s - 1, r1 = w0 * l1 + w1 * m1 + w2 * s1, r2 = w0 * l2 + w1 * m2 + w2 * s2;
    const u = r1 / (r1 * r1 - 0.5 * r * r2);
    return u >= 0 ? -r * u : Infinity;
  };
  return t + Math.min(step([4.0767416621, -3.3077115913, 0.2309699292]), step([-1.2684380046, 2.6097574011, -0.3413193965]), step([-0.0041960863, -0.7034186147, 1.7076147010]));
}
function okCs(L, a, b) {
  const cusp = findCusp(a, b), Cmax = gamutIntersection(a, b, L, 1, L, cusp);
  const STmax = [cusp[1] / cusp[0], cusp[1] / (1 - cusp[0])];
  const Smid = 0.11516993 + 1 / (7.44778970 + 4.15901240 * b + a * (-2.19557347 + 1.75198401 * b + a * (-2.13704948 - 10.02301043 * b + a * (-4.24894561 + 5.38770819 * b + 4.69891013 * a))));
  const Tmid = 0.11239642 + 1 / (1.61320320 - 0.68124379 * b + a * (0.40370612 + 0.90148123 * b + a * (-0.27087943 + 0.61223990 * b + a * (0.00299215 - 0.45399568 * b - 0.14661872 * a))));
  const k = Cmax / Math.min(L * STmax[0], (1 - L) * STmax[1]);
  const Cmid = 0.9 * k * Math.sqrt(Math.sqrt(1 / (1 / (L * Smid) ** 4 + 1 / ((1 - L) * Tmid) ** 4)));
  const C0 = Math.sqrt(1 / (1 / (L * 0.4) ** 2 + 1 / ((1 - L) * 0.8) ** 2));
  return [C0, Cmid, Cmax];
}
const TK1 = 0.206, TK2 = 0.03, TK3 = (1 + TK1) / (1 + TK2);
const toe = x => 0.5 * (TK3 * x - TK1 + Math.sqrt((TK3 * x - TK1) ** 2 + 4 * TK2 * TK3 * x));
const toeInv = x => (x * x + TK1 * x) / (TK3 * (x + TK2));
function toOkhsl(hex) {
  const [L, a, b] = oklab(hex), C = Math.hypot(a, b), l = toe(L);
  if (C < 2e-4 || L <= 0 || L >= 1) return [l, 0, NaN];
  const [C0, Cmid, Cmax] = okCs(L, a / C, b / C);
  let s;
  if (C < Cmid) { const k1 = 0.8 * C0, k2 = 1 - k1 / Cmid; s = 0.8 * C / (k1 + k2 * C); }
  else { const k1 = 0.2 * Cmid * Cmid * 1.5625 / C0, k2 = 1 - k1 / (Cmax - Cmid); s = 0.8 + 0.2 * (C - Cmid) / (k1 + k2 * (C - Cmid)); }
  return [l, s, (Math.atan2(b, a) / RAD + 360) % 360];
}
function okhslLinear(l, s, h) {
  if (l >= 1) return [1, 1, 1];
  if (l <= 0) return [0, 0, 0];
  const a = Math.cos(h * RAD), b = Math.sin(h * RAD), L = toeInv(l);
  const [C0, Cmid, Cmax] = okCs(L, a, b);
  let C;
  if (s < 0.8) { const t = 1.25 * s, k1 = 0.8 * C0, k2 = 1 - k1 / Cmid; C = t * k1 / (1 - k2 * t); }
  else { const t = (s - 0.8) / 0.2, k1 = 0.2 * Cmid * Cmid * 1.5625 / C0, k2 = 1 - k1 / (Cmax - Cmid); C = Cmid + t * k1 / (1 - k2 * t); }
  return labToLinear(L, C * a, C * b);
}
const fromOkhsl = (l, s, h) => toHex(okhslLinear(l, s, h).map(l2s));

const SPACES = {
  oklch: {
    name: 'OKLCH', c: 'C', cMax: CMAX, cScale: 1, cDigits: 3,
    coords: toLch, hex: fromLch, limit: maxChroma,
    pixel: (l, c, h) => { const lin = labToLinear(l, c * Math.cos(h * RAD), c * Math.sin(h * RAD)); return linOk(lin) ? lin.map(l2s) : null; },
    fmt: (l, c, h) => `oklch(${(l * 100).toFixed(1)}% ${c.toFixed(3)} ${h.toFixed(1)})`,
    short: (l, c, h) => `L ${(l * 100).toFixed(1)}  C ${c.toFixed(3)}  H ${Number.isNaN(h) ? '–' : h.toFixed(0) + '°'}`,
  },
  hsl: {
    name: 'HSL', c: 'S', cMax: 1, cScale: 100, cDigits: 1,
    coords: toHsl, hex: fromHsl, limit: () => 1,
    pixel: (l, c, h) => hslRgb(l, c, h).map(x => Math.round(x * 255)),
    fmt: (l, c, h) => `hsl(${h.toFixed(1)} ${(c * 100).toFixed(1)}% ${(l * 100).toFixed(1)}%)`,
    short: (l, c, h) => `H ${Number.isNaN(h) ? '–' : h.toFixed(0) + '°'}  S ${(c * 100).toFixed(0)}%  L ${(l * 100).toFixed(0)}%`,
  },
  okhsl: {
    name: 'OKHSL', c: 'S', cMax: 1, cScale: 100, cDigits: 1,
    coords: toOkhsl, hex: fromOkhsl, limit: () => 1,
    pixel: (l, c, h) => okhslLinear(l, c, h).map(l2s),
    fmt: (l, c, h) => `okhsl(${h.toFixed(1)} ${(c * 100).toFixed(1)}% ${(l * 100).toFixed(1)}%)`,
    short: (l, c, h) => `H ${Number.isNaN(h) ? '–' : h.toFixed(0) + '°'}  S ${(c * 100).toFixed(0)}%  L ${(l * 100).toFixed(0)}%`,
  },
};

// The rotation that puts six hues, in red-to-magenta order, closest to 60° steps:
// the circular mean of each hue minus its slot.
function bestStart(hues) {
  let x = 0, y = 0;
  hues.forEach((h, i) => { if (!Number.isNaN(h)) { x += Math.cos((h - 60 * i) * RAD); y += Math.sin((h - 60 * i) * RAD); } });
  return (Math.atan2(y, x) / RAD + 360) % 360;
}

// --- editor roles: colours beyond the six hues, each kept as an OKHSL
// offset (lightness, saturation, hue) from the Tetra colour it sits beside, so
// it follows when that colour changes. OKHSL keeps every result inside sRGB.
const ROLE_BASE = { tag: 'bright_blue', special: 'accent', operator: 'orange', error: 'bright_red', vcs_added: 'bright_green', vcs_modified: 'bright_magenta', vcs_removed: 'bright_red' };
const ROLE_KEYS = Object.keys(ROLE_BASE);
// [role colour, the colour it was measured against], from the stock Neovim theme's palette
const SOURCE_ROLES = {
  dark:   { tag: ['#39bae6', '#59c2ff'], special: ['#e6b673', '#e6b450'], operator: ['#f29668', '#ff8f40'], error: ['#d95757', '#f07178'], vcs_added: ['#7fd962', '#aad94c'], vcs_modified: ['#73b8ff', '#59c2ff'], vcs_removed: ['#f26d78', '#f07178'] },
  mirage: { tag: ['#5ccfe6', '#73d0ff'], special: ['#ffdfb3', '#ffcc66'], operator: ['#f29e74', '#ffad66'], error: ['#ff6666', '#f28779'], vcs_added: ['#87d96c', '#d5ff80'], vcs_modified: ['#80bfff', '#73d0ff'], vcs_removed: ['#f27983', '#f28779'] },
  light:  { tag: ['#55b4d4', '#399ee6'], special: ['#e6ba7e', '#ffaa33'], operator: ['#ed9366', '#fa8d3e'], error: ['#e65050', '#f07171'], vcs_added: ['#6cbf43', '#86b300'], vcs_modified: ['#478acc', '#399ee6'], vcs_removed: ['#ff7383', '#f07171'] },
};
const hueDiff = (a, b) => ((a - b + 540) % 360) - 180;
function okOffset(hex, baseHex) {
  const [l1, s1, h1] = toOkhsl(hex), [l0, s0, h0] = toOkhsl(baseHex);
  return { dl: l1 - l0, ds: s1 - s0, dh: Number.isNaN(h1) || Number.isNaN(h0) ? 0 : hueDiff(h1, h0) };
}
// An offset may also scale saturation (ks, applied before ds), for roles defined as a fraction of their base.
function applyOffset(baseHex, o) {
  const [l, s, h] = toOkhsl(baseHex), clamp = x => Math.min(1, Math.max(0, x));
  return fromOkhsl(clamp(l + o.dl), clamp(s * (o.ks ?? 1) + o.ds), ((Number.isNaN(h) ? 0 : h) + o.dh + 360) % 360);
}
const SOURCE_ROLE_OFFSETS = Object.fromEntries(Object.entries(SOURCE_ROLES).map(([v, rs]) =>
  [v, Object.fromEntries(Object.entries(rs).map(([r, [hex, baseHex]]) => [r, okOffset(hex, baseHex)]))]));
// Roles Tetra defines itself, the same in every variant; the rest keep the per-variant
// offsets measured from the source palette. vcs_modified is measured from bright_magenta;
// special is accent at half its saturation.
const TETRA_ROLE_OFFSETS = {
  special: { dl: 0, ds: 0, dh: 0, ks: 0.5 },
  operator: { dl: -0.0035, ds: -0.27, dh: -9.63 },
  error: { dl: -0.0852, ds: 0.0582, dh: 7.8 },
  vcs_removed: { dl: -0.0022, ds: 0.1631, dh: 2.87 },
  vcs_modified: { dl: -0.0283, ds: -0.1524, dh: -12.32 },
};
const ROLE_DEFAULTS = Object.fromEntries(Object.keys(SOURCE_ROLES).map(v =>
  [v, Object.fromEntries(Object.keys(ROLE_BASE).map(r => [r, TETRA_ROLE_OFFSETS[r] || SOURCE_ROLE_OFFSETS[v][r]]))]));
const defaultOwner = r => r in TETRA_ROLE_OFFSETS || rules.system ? 'Tetra’s' : 'the inherited';
const fmtOffset = o => `L ${o.dl >= 0 ? '+' : '−'}${Math.abs(o.dl * 100).toFixed(1)}  S ${o.ks != null ? `×${o.ks}` : `${o.ds >= 0 ? '+' : '−'}${Math.abs(o.ds * 100).toFixed(1)}`}  H ${o.dh >= 0 ? '+' : '−'}${Math.abs(o.dh).toFixed(1)}°`;

// --- theme rules, shared by all variants. Neutral shades: each background and
// foreground becomes the grey with the same OKLab lightness, so the steps
// between them stay as they were. Selection from accent: selection sits at
// accent's opposite OKHSL hue, keeps its own OKHSL saturation, and its OKHSL
// lightness is a percentage of the way from black to accent's, or in a light
// theme from white to accent's, so it stays close to the background. Muted from selection: muted takes
// selection's OKHSL hue and saturation at its own OKHSL lightness, so it keeps
// its contrast as text. Hue layout: the hues
// sit at 60° steps from red (OKHSL hue, which is OKLCH's), with brown in the
// slot after red and yellow and orange split either side of it; each colour
// keeps its own OKHSL lightness and saturation. ---
const NEUTRAL_KEYS = ['background', 'dark_background', 'darker_background', 'lighter_background', 'foreground', 'dark_foreground', 'light_foreground', 'bright_foreground'];
const HUE_SLOTS = { red: 0, bright_red: 0, brown: 1, yellow: 1, bright_yellow: 1, orange: 1, green: 2, bright_green: 2, cyan: 3, bright_cyan: 3, blue: 4, bright_blue: 4, magenta: 5, bright_magenta: 5 };
const SPLIT_SIGN = { yellow: 1, bright_yellow: 1, orange: -1 };   // toward green, toward red
const ruleHue = (rules, k) => (rules.red + 60 * HUE_SLOTS[k] + (SPLIT_SIGN[k] || 0) * rules.split + 360) % 360;
const neutralOf = hex => fromOklab(oklab(hex)[0], 0, 0);
function applyRules(rules, c, mode) {
  if (rules.neutral) for (const k of NEUTRAL_KEYS) c[k] = neutralOf(c[k]);
  if (rules.hues) for (const k of Object.keys(HUE_SLOTS)) { const [l, sat] = toOkhsl(c[k]); c[k] = fromOkhsl(l, sat, ruleHue(rules, k)); }
  if (rules.selFromAccent) {
    const [al, , ah] = toOkhsl(c.accent), [, sat] = toOkhsl(c.selection);
    const p = rules.selPct / 100, l = mode === 'light' ? 1 - p * (1 - al) : p * al;
    c.selection = fromOkhsl(l, sat, ((Number.isNaN(ah) ? 0 : ah) + 180) % 360);
  }
  if (rules.mutedFromSel) { const [, sat, h] = toOkhsl(c.selection), [l] = toOkhsl(c.muted); c.muted = fromOkhsl(l, sat, Number.isNaN(h) ? 0 : h); }
  return c;
}

// --- the system: Dark's palette, after the rules above, is the definition.
// Each variant supplies a ground (the OKHSL lightness of its background and
// foreground) and an accent. Every colour keeps Dark's OKHSL hue and saturation.
// Neutrals, muted and selection sit at the same position between background and
// foreground. The hues (bright colours, orange and brown) keep Dark's lightness
// distance from the background, scaled by the light-ground depth on a light
// variant, so the foreground never moves them. Normal colours are their bright
// colour darkened by Dark's step, then held to 4.5:1 on the background. A
// variant is light when its background is lighter than its foreground. ---
const clamp01 = x => Math.min(1, Math.max(0, x));
const POSITIONED = [...NEUTRAL_KEYS, 'muted', 'selection'];
const DISTANCED = ['orange', 'brown', ...HUES.map(h => 'bright_' + h)];
const SUNK = ['dark_background', 'darker_background'];   // Omarchy's light themes put these below the background
const groundOf = c => ({ bg: toOkhsl(c.background)[0], fg: toOkhsl(c.foreground)[0] });
const modeOfGround = g => g.bg > g.fg ? 'light' : 'dark';
function placeOnGround(src, ground, accent, lightDepth = 1) {
  const sg = groundOf(src), mode = modeOfGround(ground), out = { ...src };
  const okhsl = k => { const [l, s, h] = toOkhsl(src[k]); return [l, s, Number.isNaN(h) ? 0 : h]; };
  for (const k of POSITIONED) {
    const [l, s, h] = okhsl(k);
    let t = (l - sg.bg) / (sg.fg - sg.bg);
    if (mode === 'light' && SUNK.includes(k)) t = Math.abs(t);
    out[k] = fromOkhsl(clamp01(ground.bg + t * (ground.fg - ground.bg)), s, h);
  }
  const away = Math.sign(ground.fg - ground.bg), depth = mode === 'light' ? lightDepth : 1;
  for (const k of DISTANCED) {
    const [l, s, h] = okhsl(k);
    out[k] = fromOkhsl(clamp01(ground.bg + away * depth * Math.abs(l - sg.bg)), s, h);
  }
  out.accent = accent;
  for (const k of HUES) {
    const [l, s, h] = okhsl(k), step = l - okhsl('bright_' + k)[0];
    let nl = toOkhsl(out['bright_' + k])[0] + step, hex = fromOkhsl(clamp01(nl), s, h);
    for (let i = 0; i < 200 && contrast(hex, out.background) < 4.5; i++) { nl += away * 0.005; hex = fromOkhsl(clamp01(nl), s, h); }
    out[k] = hex;
  }
  return out;
}

// --- state ---
const tweaks = Object.fromEntries(VARIANTS.map(v => [v, {}]));       // palette keys that differ from the generator
const roleTweaks = Object.fromEntries(VARIANTS.map(v => [v, {}]));   // role offsets that differ from the defaults
const base = v => ({ ...DATA[v].colors, ...tweaks[v] });
let preview = {};   // even-hues preview for the current variant, never saved until applied
const roleDefaults = v => rules.system ? ROLE_DEFAULTS.dark : ROLE_DEFAULTS[v];   // the system measures every role from Dark
// In the system, Dark's role edits reach every variant unless the variant has its own.
const roleOffset = (v, r) => roleTweaks[v][r] || (rules.system && roleTweaks.dark[r]) || roleDefaults(v)[r];
function withRoles(v, c) { for (const r of ROLE_KEYS) c[r] = applyOffset(c[ROLE_BASE[r]], roleOffset(v, r)); return c; }
const RULE_VALUE_DEFAULTS = { red: 12, split: 20, selPct: 30, lightDepth: 60 };   // the panel's numbers; grounds default to each variant's own
const rules = { neutral: false, hues: false, selFromAccent: false, mutedFromSel: false, ...RULE_VALUE_DEFAULTS, system: false, grounds: {} };
// Grounds Tetra sets itself (OKHSL lightness); the rest are each variant's generated background and foreground.
const TETRA_GROUNDS = { mirage: { bg: 0.135, fg: 0.833 }, light: { bg: 0.968, fg: 0.255 } };
const DEFAULT_GROUNDS = Object.fromEntries(VARIANTS.map(v => [v, TETRA_GROUNDS[v] || groundOf(DATA[v].colors)]));
const srcPalette = darkTweaks => applyRules(rules, { ...DATA.dark.colors, ...darkTweaks, ...(variant === 'dark' ? preview : {}) }, 'dark');
function groundFor(v, src) {
  const g = rules.grounds[v], d = v === 'dark' ? groundOf(src) : DEFAULT_GROUNDS[v];
  return { bg: g?.bg ?? d.bg, fg: g?.fg ?? d.fg };
}
// A variant in the system: Dark's palette (with Dark's edits) placed on the variant's ground,
// then the variant's own edits, then the selection and muted rules for its ground and accent.
function systemPalette(v, darkTweaks, own) {
  const src = srcPalette(darkTweaks), ground = groundFor(v, src);
  const { accent, ...rest } = own;
  const c = Object.assign(placeOnGround(src, ground, accent || src.accent, rules.lightDepth / 100), rest);
  return applyRules({ ...rules, neutral: false, hues: false }, c, modeOfGround(ground));
}
const modeOf = v => rules.system ? modeOfGround(groundFor(v, srcPalette(tweaks.dark))) : DATA[v].mode;
const eff = v => withRoles(v, rules.system
  ? systemPalette(v, tweaks.dark, v === 'dark' ? {} : tweaks[v])
  : applyRules(rules, v === variant ? { ...base(v), ...preview } : base(v), DATA[v].mode));
const ruled = k => (rules.neutral && NEUTRAL_KEYS.includes(k)) || (rules.hues && k in HUE_SLOTS) || (rules.mutedFromSel && k === 'muted') || (rules.selFromAccent && k === 'selection');
// What the picker may not move for a key because a rule sets it.
const locks = k => {
  const neutral = rules.neutral && NEUTRAL_KEYS.includes(k), fromSel = rules.mutedFromSel && k === 'muted', fromAccent = rules.selFromAccent && k === 'selection';
  return { h: neutral || fromSel || fromAccent || (rules.hues && k in HUE_SLOTS), c: neutral || fromSel, l: fromAccent };
};
const isRole = k => k in ROLE_BASE;
// What a key is with no edits of mine: the generator's value under the current rules, or for a
// role, its default offset from its base as it stands. "Changed" and "Reset" measure against this.
const baseline = v => rules.system ? systemPalette(v, v === 'dark' ? {} : tweaks.dark, {}) : applyRules(rules, { ...DATA[v].colors }, DATA[v].mode);
const genOf = (v, k) => isRole(k) ? applyOffset(eff(v)[ROLE_BASE[k]], (rules.system && v !== 'dark' && roleTweaks.dark[k]) || roleDefaults(v)[k]) : baseline(v)[k];
function changeCount(v) {   // edits that still make a difference under the current rules
  const c = eff(v), b = baseline(v);
  return Object.keys(tweaks[v]).filter(k => c[k] !== b[k]).length + Object.keys(roleTweaks[v]).length;
}
let variant, refs = {}, db = null, readOnly = false;
let space = 'okhsl';
try { if (SPACES[localStorage.getItem('tetra-space')]) space = localStorage.getItem('tetra-space'); } catch {}
const even = { on: false, start: 0 };

const $ = id => document.getElementById(id);
const el = (tag, attrs = {}, kids = []) => { const e = document.createElement(tag); for (const [k, v] of Object.entries(attrs)) k === 'style' ? e.style.cssText = v : k === 'text' ? e.textContent = v : e.setAttribute(k, v); for (const k of [].concat(kids)) e.append(k); return e; };
const ink = (h, c) => contrast(h, c.background) > contrast(h, c.bright_foreground) ? c.background : c.bright_foreground;

function how(v, key) {
  if (key === 'accent') return 'source accent, as-is';
  if (key === 'selection') return 'source selection, half tint';
  if (key === 'muted') return 'source comment grey, half tint';
  if (key === 'orange' || key === 'brown') return 'base24 source, as-is';
  if (key.endsWith('background') || key.endsWith('foreground'))
    return v === 'light' && key === 'dark_background' ? 'source sunk surface, half tint' : v === 'light' && key === 'darker_background' ? 'sunk mixed 8% to fg, half tint' : 'base24 source, half tint';
  if (key.startsWith('bright_')) return v === 'mirage' && key === 'bright_red' ? 'source palette +0.02 L' : 'source palette, as-is';
  if (v === 'light') return 'darkened to 4.5:1';
  return v === 'mirage' && key === 'red' ? 'bright −0.05 L' : 'bright −0.07 L';
}

// --- palette editor: built once per variant, then refreshed in place so a
// picker or hex field keeps focus while its colour changes ---
function swatchParts(key) {
  const block = el('button', { class: 'block', type: 'button', 'aria-label': `Edit ${key} in the picker`, 'aria-pressed': 'false' });
  const was = el('span', { class: 'src', hidden: '' });   // the default colour, shown once an edit moves away from it
  block.append(was);
  const hexin = el('input', { class: 'hexin', 'aria-label': `${key} hex`, spellcheck: 'false', autocomplete: 'off', maxlength: '7' });
  const howEl = el('span', { class: 'how' });
  const coord = el('span', { class: 'cr coord' });
  const ratio = el('span', { class: 'cr' });
  const reset = el('button', { class: 'reset', type: 'button' });
  const meta = el('div', {}, [el('span', { class: 'name', text: key }), hexin, coord, howEl, ratio, reset]);

  block.addEventListener('click', () => openPicker(key));
  hexin.addEventListener('input', () => {
    const h = (hexin.value.startsWith('#') ? hexin.value : '#' + hexin.value).toLowerCase();
    hexin.setAttribute('aria-invalid', !HEX.test(h));
    if (HEX.test(h)) setColor(key, h);
  });
  hexin.addEventListener('blur', () => { hexin.removeAttribute('aria-invalid'); hexin.value = eff(variant)[key]; });
  hexin.addEventListener('keydown', e => { if (e.key === 'Enter') hexin.blur(); });
  reset.addEventListener('click', () => setColor(key, genOf(variant, key)));
  refs[key] = { block, was, hexin, coord, howEl, ratio, reset, meta };
  return { block, meta };
}
function card(keys) {
  const parts = keys.map(swatchParts);
  return el('div', { class: 'sw' }, [
    el('div', { class: 'chipset' }, parts.map(p => p.block)),
    el('div', { class: 'meta' }, parts.map(p => p.meta)),
  ]);
}
function group(title, cls, cards) { return el('div', { class: 'group' }, [el('h3', { text: title }), el('div', { class: cls }, cards)]); }

function buildPalette() {
  refs = {};
  const g = DATA[variant].colors;
  $('groups').replaceChildren(
    group('Accent and UI', 'grid', ['accent', 'selection', 'muted'].map(k => card([k]))),
    group('Backgrounds, darkest to lightest', 'grid', ['darker_background', 'dark_background', 'background', 'lighter_background'].sort((a, b) => lum(g[a]) - lum(g[b])).map(k => card([k]))),
    group('Foregrounds', 'grid', ['dark_foreground', 'foreground', 'light_foreground', 'bright_foreground'].map(k => card([k]))),
    group('Hues, normal and bright', 'grid pairs', HUES.map(h => card([h, 'bright_' + h]))),
    group('Extras', 'grid', ['orange', 'brown'].map(k => card([k]))),
    group('Editor roles, as OKHSL offsets', 'grid', ['tag', 'special', 'operator', 'error'].map(k => card([k]))),
    group('Version control', 'grid', ['vcs_added', 'vcs_modified', 'vcs_removed'].map(k => card([k]))),
  );
}
function refreshPalette(c) {
  for (const [key, r] of Object.entries(refs)) {
    const hex = c[key], gen = genOf(variant, key), changed = isRole(key) ? !!roleTweaks[variant][key] : hex !== gen;
    const placed = rules.system && variant !== 'dark' && !isRole(key);
    const rule = placed && key === 'accent' ? (tweaks[variant].accent ? 'this variant’s accent input' : 'Dark’s accent')
      : placed && rules.selFromAccent && key === 'selection' ? `opposite accent’s hue, ${rules.selPct}% of the way from ${modeOf(variant) === 'light' ? 'white' : 'black'} to its lightness`
      : placed && rules.mutedFromSel && key === 'muted' ? 'Dark’s lightness position, selection’s hue and saturation'
      : placed && HUES.includes(key) ? `bright_${key} darkened by Dark’s step, at least 4.5:1`
      : placed && DISTANCED.includes(key) ? `Dark’s distance from the background${modeOf(variant) === 'light' ? `, at ${rules.lightDepth}% depth` : ''}`
      : placed && POSITIONED.includes(key) ? `Dark’s ${key}, ${placedPct(key)}% of the way to the foreground`
      : rules.neutral && NEUTRAL_KEYS.includes(key) ? `neutral grey at OKLab L ${(oklab(hex)[0] * 100).toFixed(1)}`
      : rules.hues && key in HUE_SLOTS ? `hue layout, ${ruleHue(rules, key).toFixed(1)}°`
      : rules.mutedFromSel && key === 'muted' ? 'selection’s hue and saturation at its own lightness'
      : rules.selFromAccent && key === 'selection' ? `opposite accent’s hue, ${rules.selPct}% of the way from ${modeOf(variant) === 'light' ? 'white' : 'black'} to its lightness` : '';
    r.block.style.background = hex;
    r.was.hidden = !changed;
    if (changed) { r.was.style.background = gen; r.was.style.color = ink(gen, c); r.was.textContent = 'default'; r.was.title = `Default ${gen}`; }
    r.block.setAttribute('aria-pressed', key === pk.key);
    if (document.activeElement !== r.hexin) r.hexin.value = hex;
    r.coord.textContent = SPACES[space].short(...SPACES[space].coords(hex));
    r.meta.classList.toggle('mod', changed);
    r.howEl.textContent = isRole(key)
      ? `${ROLE_BASE[key]} ${fmtOffset(roleOffset(variant, key))}` + (changed ? `; ${defaultOwner(key)} is ${fmtOffset(roleDefaults(variant)[key])}` : `, ${defaultOwner(key)} offset`)
      : rule ? rule + (changed ? `; edited, the rule alone gives ${gen}` : '')
      : changed ? `${how(variant, key)}; edited, generated ${gen}` : how(variant, key) + (DATA[variant].source[key] && DATA[variant].source[key] !== gen ? ` (from ${DATA[variant].source[key]})` : '');
    r.reset.hidden = !changed;
    r.reset.textContent = `Reset to ${gen}`;
    const isShade = key.endsWith('background');
    const ratio = isShade ? contrast(c.foreground, hex) : contrast(hex, c.background);
    r.ratio.className = 'cr' + (!isShade && ratio < 3 ? ' low' : '');
    r.ratio.textContent = key === 'background' ? `fg ${ratio.toFixed(1)}:1` : (isShade ? 'fg ' : '') + ratio.toFixed(1) + ':1' + (!isShade && ratio < 3 ? ' low' : !isShade && ratio < 4.5 ? ' large only' : '');
  }
}

// --- everything else is cheap to redraw on each change ---
function paint() {
  const c = eff(variant), d = derive(variant, c, modeOf(variant)), p = d.paseo, root = document.documentElement.style;
  const page = { bg: c.background, surface: c.lighter_background, sunk: c.dark_background, control: p.control, line: p.border,
    fg: c.foreground, strong: c.bright_foreground, soft: p.mutedForeground, muted: c.muted, accent: c.accent, 'accent-ink': p.accent, sel: c.selection, warn: variant === 'light' ? c.red : c.bright_red };
  for (const [k, v] of Object.entries(page)) root.setProperty('--' + k, v);
  for (const [k, v] of Object.entries(c)) root.setProperty('--c-' + k, v);
  // todo-comments badge text: white or black, whichever contrasts more (black on a tie)
  for (const [k, v] of Object.entries(c)) root.setProperty('--ink-' + k, contrast(v, '#ffffff') > contrast(v, '#000000') ? '#ffffff' : '#000000');
  root.setProperty('--c-status', d.status);
  root.setProperty('--c-inactive', 'rgba(89, 89, 89, .667)');
  root.setProperty('--wall-a', d.wall[0]);
  root.setProperty('--wall-b', d.wall[1]);
  root.colorScheme = modeOf(variant);

  $('notif-title').textContent = $('paseo-name').textContent = TITLES[variant];
  for (const m of document.querySelectorAll('[data-menu]')) m.classList.toggle('sel', m.dataset.menu === variant);
  for (const b of document.querySelectorAll('#seg button')) {
    b.setAttribute('aria-pressed', b.dataset.v === variant);
    b.querySelector('.dot').style.background = eff(b.dataset.v).background;
  }

  refreshPalette(c);
  const all = { ...c, status: d.status };
  $('slots').replaceChildren(...SLOTS.map(([key, role], i) => el('div', { class: 'slot' }, [
    el('div', { class: 's-c', style: `background:${all[key]};color:${ink(all[key], c)}`, text: i }),
    el('div', { class: 's-t' }, [el('b', { text: role }), el('button', { class: 'hex', 'data-hex': all[key], text: all[key] })]),
  ])));
  $('paseo').replaceChildren(...Object.entries(p).map(([k, v]) =>
    el('div', {}, [el('i', { style: `background:${v}` }), el('span', {}, [k, el('code', { class: 'hex', 'data-hex': v, text: v })])])));
  renderCompare();
  renderRules();
  renderTools();
  syncPicker();
}

function renderCompare() {
  $('compare').replaceChildren(...VARIANTS.map(v => {
    const c = eff(v), n = changeCount(v);
    const b = el('button', { class: 'mini', 'data-v': v, style: `background:${c.background};color:${c.foreground};border-color:${c.accent}` }, [
      el('span', { class: 't', style: `color:${c.bright_foreground}`, text: TITLES[v] }),
      el('span', {}, [el('span', { style: `color:${c.green}`, text: '~/src' }), ' > ', el('span', { style: `color:${c.blue}`, text: 'git' }), ' ', el('span', { style: `color:${c.cyan}`, text: 'log' }), el('span', { style: `color:${c.muted}`, text: ' --oneline' })]),
      el('div', { class: 'dots' }, SLOTS.slice(0, 16).map(([k]) => el('i', { style: `background:${c[k]};box-shadow:0 0 0 1px ${c.lighter_background}` }))),
      el('span', { class: 'here', style: `color:${c.accent}`, text: (v === variant ? 'Showing' : 'Show this one') + (n ? ` · ${n} changed` : '') }),
    ]);
    b.addEventListener('click', () => { select(v); window.scrollTo({ top: 0, behavior: matchMedia('(prefers-reduced-motion: reduce)').matches ? 'auto' : 'smooth' }); });
    return b;
  }));
}


// --- picker: hue and chroma (or saturation) on a wheel, lightness on a strip,
// every palette colour plotted on both so the edited one is seen against the rest ---
const ROWS = { shade: 'shades', normal: 'normal', bright: 'bright', role: 'roles' };
const ALL_KEYS = KEYS.concat(ROLE_KEYS);
const rowOf = k => isRole(k) ? 'role' : HUES.includes(k) ? 'normal' : k.startsWith('bright_') && k !== 'bright_foreground' || ['accent', 'orange', 'brown'].includes(k) ? 'bright' : 'shade';
const isShade = k => k.endsWith('background');
const pk = { key: null, l: 0, c: 0, h: 0, hex: null, wheel: null };
const svgNS = 'http://www.w3.org/2000/svg';
const sv = (tag, attrs = {}) => { const e = document.createElementNS(svgNS, tag); for (const [k, v] of Object.entries(attrs)) e.setAttribute(k, v); return e; };
const css = name => getComputedStyle(document.documentElement).getPropertyValue(name).trim();
const sp = () => SPACES[space];
const coordsOf = hex => { const [l, c, h] = sp().coords(hex); return [l, c, h]; };

function loadPicker() {
  const hex = eff(variant)[pk.key], [l, c, h] = coordsOf(hex);
  pk.l = l; pk.c = c; pk.h = Number.isNaN(h) ? pk.h : h; pk.hex = hex;
}
function openPicker(key) {
  pk.key = key;
  loadPicker();
  $('picker').hidden = false;
  paint();
}
function closePicker() {
  const key = pk.key;
  if (even.on) setEven(false);
  pk.key = null;
  $('picker').hidden = true;
  paint();
  refs[key]?.block.focus();
}
function syncPicker() {
  if (!pk.key) return;
  if (eff(variant)[pk.key] !== pk.hex) loadPicker();   // changed elsewhere: hex field, reset, preview, another tab
  drawPicker();
}
function commit() {
  if (even.on) return;
  setColor(pk.key, sp().hex(pk.l, pk.c, pk.h));
  pk.hex = eff(variant)[pk.key];   // a role comes back through its offset; keep the picker from reloading mid-drag
}
function setSpace(s) {
  if (s === space) return;
  space = s;
  try { localStorage.setItem('tetra-space', s); } catch {}
  pk.wheel = null;
  if (pk.key) loadPicker();
  if (even.on) { even.start = bestStart(HUES.map(k => sp().coords(base(variant)['bright_' + k])[2])); computeEven(); }
  paint();
}

// --- even hues: every hue pair moved to start + 60° × slot, each colour
// keeping its own lightness and chroma in the current space ---
function computeEven() {
  const b = base(variant);
  preview = {};
  HUES.forEach((k, i) => {
    for (const key of [k, 'bright_' + k]) {
      const [l, c] = sp().coords(b[key]);
      const hex = sp().hex(l, c, (even.start + 60 * i) % 360);
      if (hex !== b[key]) preview[key] = hex;
    }
  });
}
function setEven(on) {
  even.on = on;
  if (on) { even.start = bestStart(HUES.map(k => sp().coords(base(variant)['bright_' + k])[2])); computeEven(); }
  else preview = {};
  paint();
}
function applyEven() {
  for (const [k, h] of Object.entries(preview)) { if (h === DATA[variant].colors[k]) delete tweaks[variant][k]; else tweaks[variant][k] = h; }
  even.on = false;
  preview = {};
  paint();
  scheduleSave(variant);
}

function drawPicker() {
  const s = sp(), c = eff(variant), gen = genOf(variant, pk.key), limit = s.limit(pk.l, pk.h);
  $('pk-swatch').style.background = pk.hex;
  $('pk-name').textContent = pk.key;
  $('pk-hex').textContent = $('pk-hex').dataset.hex = pk.hex;
  $('pk-coord').textContent = $('pk-coord').dataset.hex = s.fmt(pk.l, Math.min(pk.c, limit), pk.h);
  $('pk-reset').hidden = even.on || (isRole(pk.key) ? !roleTweaks[variant][pk.key] : pk.hex === gen);
  $('pk-reset').textContent = `Reset to ${gen}`;
  const lk = locks(pk.key);
  $('pk-gamut').textContent = rules.selFromAccent && pk.key === 'selection' ? 'Hue and lightness come from accent; only saturation changes.'
    : rules.mutedFromSel && pk.key === 'muted' ? 'Hue and saturation come from selection; only lightness changes.'
    : lk.c ? 'The neutral shades rule keeps this grey; only lightness changes.'
    : lk.h ? 'The hue layout rule sets this hue.'
    : pk.c > limit + 5e-4 ? `Past sRGB at this lightness and hue; using chroma ${limit.toFixed(3)}.` : '';
  $('pk-gamut').className = lk.c || lk.h ? '' : 'warn';
  $('pk-contrast').textContent = isShade(pk.key) ? `foreground on it ${contrast(c.foreground, pk.hex).toFixed(1)}:1` : `${contrast(pk.hex, c.background).toFixed(1)}:1 on background`;
  $('pk-C-label').textContent = s.c;
  $('pk-Cn').setAttribute('aria-label', s.c === 'C' ? 'Chroma' : 'Saturation, percent');
  $('pk-wheel-cap').textContent = {
    oklch: 'The wheel is a slice at this colour’s OKLCH lightness: hue around, chroma outward, striped where sRGB can’t reach. Equal steps look roughly equal.',
    hsl: 'The wheel is a slice at this colour’s HSL lightness: hue around, saturation outward. Every point is displayable, but equal HSL lightness doesn’t look equally light: compare yellow and blue on the strip.',
    okhsl: 'The wheel is a slice at this colour’s OKHSL lightness: OKLCH’s hue around, saturation outward, where 100% is the most colourful sRGB can show at that hue and lightness. Lightness tracks what you see, and nothing is out of range.',
  }[space];
  drawEven();
  drawWheel();
  drawWheelMarks(c);
  drawStrip(c);
  drawSliders(limit);
}

function drawEven() {
  $('pk-even').checked = even.on;
  $('pk-even-ctl').hidden = !even.on;
  $('picker').classList.toggle('previewing', even.on);
  const lk = locks(pk.key);
  for (const id of ['pk-L', 'pk-Ln']) $(id).disabled = even.on || lk.l;
  for (const id of ['pk-C', 'pk-Cn']) $(id).disabled = even.on || lk.c;
  for (const id of ['pk-H', 'pk-Hn']) $(id).disabled = even.on || lk.h;
  $('pk-even').disabled = rules.hues || rules.system;
  $('pk-even').parentElement.title = rules.hues ? 'The hue layout rule sets the hues; turn it off to preview even hues' : '';
  if (!even.on) { $('pk-even-moves').textContent = ''; return; }
  if (document.activeElement !== $('pk-even-startn')) $('pk-even-startn').value = even.start.toFixed(1);
  $('pk-even-start').value = even.start;
  const b = base(variant);
  $('pk-even-moves').textContent = `Moves in ${sp().name}: ` + HUES.map((k, i) => {
    const h = sp().coords(b['bright_' + k])[2], d = ((even.start + 60 * i - h + 540) % 360) - 180;
    return `${k} ${d >= 0 ? '+' : '−'}${Math.abs(d).toFixed(1)}°`;
  }).join(', ') + '. Normal and bright colours move together.';
}

function drawWheel() {
  const key = `${space} ${pk.l}`;
  if (pk.wheel === key) return;
  const cv = $('pk-wheel'), dpr = space === 'okhsl' ? 1 : Math.min(2, devicePixelRatio || 1), size = Math.round(cv.clientWidth * dpr);
  if (!size) return;
  pk.wheel = key;
  cv.width = cv.height = size;
  const s = sp(), ctx = cv.getContext('2d'), img = ctx.createImageData(size, size), R = size / 2;
  for (let y = 0; y < size; y++) for (let x = 0; x < size; x++) {
    const dx = x - R + 0.5, dy = R - y - 0.5, r = Math.hypot(dx, dy);
    if (r > R) continue;
    const px = s.pixel(pk.l, r / R * s.cMax, (Math.atan2(dy, dx) / RAD + 360) % 360);
    if (!px) continue;
    const i = (y * size + x) * 4;
    img.data[i] = px[0]; img.data[i + 1] = px[1]; img.data[i + 2] = px[2]; img.data[i + 3] = 255;
  }
  ctx.putImageData(img, 0, 0);
}

function drawWheelMarks(c) {
  const s = sp(), svg = $('pk-wheel-marks'), R = 130;
  const pos = (cc, h) => { const r = Math.min(cc, s.cMax) / s.cMax * R, a = (Number.isNaN(h) ? 0 : h) * RAD; return [R + r * Math.cos(a), R - r * Math.sin(a)]; };
  const kids = [];
  const rings = space === 'oklch' ? [0.1, 0.2, 0.3] : [0.25, 0.5, 0.75, 1];   // chroma, or saturation
  for (const ring of rings) {
    kids.push(sv('circle', { class: 'grid', cx: R, cy: R, r: ring / s.cMax * R }));
    kids.push(Object.assign(sv('text', { class: 'tick', x: R + 3, y: R - ring / s.cMax * R + 10 }), { textContent: space === 'oklch' ? ring.toFixed(1) : ring * 100 + '%' }));
  }
  for (let h = 0; h < 360; h += 30) { const [x, y] = pos(s.cMax, h); kids.push(sv('line', { class: 'grid', x1: R, y1: R, x2: x, y2: y })); }
  if (even.on) {
    const b = base(variant);
    HUES.forEach((k, i) => { const [x, y] = pos(s.cMax, even.start + 60 * i); kids.push(sv('line', { class: 'guide', x1: R, y1: R, x2: x, y2: y })); });
    for (const k of Object.keys(preview)) {   // where each colour was, and where it goes
      const [, c0, h0] = coordsOf(b[k]), [, c1, h1] = coordsOf(preview[k]);
      const [x0, y0] = pos(c0, h0), [x1, y1] = pos(c1, h1);
      kids.push(sv('line', { class: 'move', x1: x0, y1: y0, x2: x1, y2: y1 }));
      kids.push(Object.assign(sv('circle', { class: 'ghost', cx: x0, cy: y0, r: 4 }), {}));
    }
  }
  for (const h of HUES) {   // tie each normal colour to its bright one
    const [, c1, h1] = coordsOf(c[h]), [, c2, h2] = coordsOf(c['bright_' + h]);
    const [x1, y1] = pos(c1, h1), [x2, y2] = pos(c2, h2);
    kids.push(sv('line', { class: 'pair', x1, y1, x2, y2 }));
  }
  for (const r of ROLE_KEYS) {   // tie each role to the colour it's measured from
    const [x1, y1] = pos(...coordsOf(c[ROLE_BASE[r]]).slice(1)), [x2, y2] = pos(...coordsOf(c[r]).slice(1));
    kids.push(sv('line', { class: 'link', x1, y1, x2, y2 }));
  }
  for (const k of ALL_KEYS.filter(k => k !== pk.key).concat(pk.key)) {   // selected on top
    const sel = k === pk.key, [, cc, h] = sel ? [pk.l, Math.min(pk.c, s.limit(pk.l, pk.h)), pk.h] : coordsOf(c[k]);
    const [x, y] = pos(cc, h);
    const dot = sv('circle', { class: 'dot' + (sel ? ' sel' : '') + (rowOf(k) === 'shade' ? ' shade' : '') + (isRole(k) ? ' role' : ''), cx: x, cy: y, r: sel ? 8 : rowOf(k) === 'shade' ? 3.5 : 5.5, fill: sel ? pk.hex : c[k], 'data-key': k });
    dot.append(Object.assign(sv('title'), { textContent: `${k} ${c[k]}` }));
    kids.push(dot);
  }
  const [sx, sy] = pos(Math.min(pk.c, s.limit(pk.l, pk.h)), pk.h);
  kids.push(Object.assign(sv('text', { class: 'lbl', x: sx + (sx > R ? -12 : 12), y: sy - 12, 'text-anchor': sx > R ? 'end' : 'start' }), { textContent: pk.key }));
  svg.replaceChildren(...kids);
}

function drawStrip(c) {
  const s = sp(), cv = $('pk-strip'), dpr = Math.min(2, devicePixelRatio || 1), w = Math.round(cv.clientWidth * dpr), h = Math.round(cv.clientHeight * dpr);
  if (!w) return;
  cv.width = w; cv.height = h;
  const ctx = cv.getContext('2d'), warn = css('--warn'), ok = css('--soft');
  for (let x = 0; x < w; x++) {
    const hex = s.hex(x / (w - 1), pk.c, pk.h);
    ctx.fillStyle = hex;
    ctx.fillRect(x, 0, 1, h - 5 * dpr);
    if (!isShade(pk.key)) { ctx.fillStyle = contrast(hex, c.background) < 4.5 ? warn : ok; ctx.fillRect(x, h - 3 * dpr, 1, 3 * dpr); }
  }
  $('pk-strip-key').hidden = isShade(pk.key);
  $('pk-strip-cap').textContent = `${s.name} lightness, 0 to 100%. Every colour sits on its row; drag the strip to set this one.`;

  const svg = $('pk-strip-marks'), W = svg.clientWidth || 400, rowY = { shade: 12, normal: 34, bright: 56, role: 78 };
  svg.setAttribute('viewBox', `0 0 ${W} 92`);
  const kids = Object.entries(ROWS).map(([r, t]) => Object.assign(sv('text', { class: 'tick', x: 0, y: rowY[r] + 4 }), { textContent: t }));
  const x0 = 50, span = W - x0 - 8;
  kids.push(sv('line', { class: 'cur', x1: x0 + pk.l * span, x2: x0 + pk.l * span, y1: 0, y2: 92 }));
  for (const k of ALL_KEYS.filter(k => k !== pk.key).concat(pk.key)) {
    const sel = k === pk.key, l = sel ? pk.l : coordsOf(c[k])[0];
    const dot = sv('circle', { class: 'dot' + (sel ? ' sel' : '') + (isRole(k) ? ' role' : ''), cx: x0 + l * span, cy: rowY[rowOf(k)], r: sel ? 7 : 5, fill: sel ? pk.hex : c[k], 'data-key': k });
    dot.append(Object.assign(sv('title'), { textContent: `${k} ${c[k]}, L ${(l * 100).toFixed(1)}%` }));
    kids.push(dot);
  }
  svg.replaceChildren(...kids);
  $('pk-strip-wrap').style.setProperty('--x0', x0 + 'px');
}

function drawSliders(limit) {
  const s = sp(), stops = (n, f) => Array.from({ length: n }, (_, i) => f(i / (n - 1))).join(', ');
  const L = $('pk-L'), C = $('pk-C'), H = $('pk-H');
  L.style.background = `linear-gradient(to right, ${stops(16, t => s.hex(t, pk.c, pk.h))})`;
  H.style.background = `linear-gradient(to right, ${stops(25, t => s.hex(pk.l, pk.c, t * 360))})`;
  // colour up to the sRGB limit, then the striped base shows through
  const edge = (limit / s.cMax * 100).toFixed(1);
  const cStops = Array.from({ length: 12 }, (_, i) => `${s.hex(pk.l, i / 11 * limit, pk.h)} ${(i / 11 * edge).toFixed(1)}%`).join(', ');
  C.style.background = `linear-gradient(to right, ${cStops}, transparent ${edge}%), repeating-linear-gradient(135deg, var(--line) 0 2px, var(--surface) 2px 6px)`;
  C.max = $('pk-Cn').max = s.cMax * s.cScale;
  C.step = $('pk-Cn').step = space === 'oklch' ? 0.001 : 0.1;
  const set = (input, num, v, digits) => { input.value = v; if (document.activeElement !== num) num.value = (+v).toFixed(digits); };
  set(L, $('pk-Ln'), pk.l * 100, 1);
  set(C, $('pk-Cn'), pk.c * s.cScale, s.cDigits);
  set(H, $('pk-Hn'), pk.h, 1);
}

function dragOn(node, onMove) {
  node.addEventListener('pointerdown', e => {
    const k = e.target.dataset?.key;
    if (k && k !== pk.key) { openPicker(k); return; }
    if (even.on) return;
    node.setPointerCapture(e.pointerId);
    onMove(e);
    const move = ev => onMove(ev);
    const up = () => { node.removeEventListener('pointermove', move); node.removeEventListener('pointerup', up); node.removeEventListener('pointercancel', up); };
    node.addEventListener('pointermove', move);
    node.addEventListener('pointerup', up);
    node.addEventListener('pointercancel', up);
  });
}
dragOn($('pk-wheel-wrap'), e => {
  const r = $('pk-wheel-wrap').getBoundingClientRect(), R = r.width / 2;
  const dx = e.clientX - r.left - R, dy = R - (e.clientY - r.top);
  const lk = locks(pk.key);
  if (lk.c && lk.h) return;
  if (!lk.c) pk.c = Math.min(sp().cMax, Math.hypot(dx, dy) / R * sp().cMax);
  if (!lk.h) pk.h = (Math.atan2(dy, dx) / RAD + 360) % 360;
  commit();
});
dragOn($('pk-strip-wrap'), e => {
  if (locks(pk.key).l) return;
  const r = $('pk-strip').getBoundingClientRect();
  pk.l = Math.min(1, Math.max(0, (e.clientX - r.left) / r.width));
  commit();
});
for (const [ch, scale] of [['l', () => 100], ['c', () => sp().cScale], ['h', () => 1]]) {
  const id = 'pk-' + ch.toUpperCase();
  $(id).addEventListener('input', e => { pk[ch] = +e.target.value / scale(); commit(); });
  const num = $(id + 'n');
  num.addEventListener('input', () => { const v = parseFloat(num.value); if (Number.isFinite(v)) { pk[ch] = Math.min(+num.max, Math.max(+num.min, v)) / scale(); commit(); } });
  num.addEventListener('blur', () => drawPicker());
}
$('pk-close').addEventListener('click', closePicker);
$('pk-reset').addEventListener('click', () => setColor(pk.key, genOf(variant, pk.key)));
$('pk-even').addEventListener('change', e => setEven(e.target.checked));
$('pk-even-start').addEventListener('input', e => { even.start = +e.target.value; computeEven(); paint(); });
$('pk-even-startn').addEventListener('input', e => { const v = parseFloat(e.target.value); if (Number.isFinite(v)) { even.start = ((v % 360) + 360) % 360; computeEven(); paint(); } });
$('pk-even-fit').addEventListener('click', () => setEven(true));
$('pk-even-apply').addEventListener('click', applyEven);
$('pk-even-discard').addEventListener('click', () => setEven(false));
$('open-picker').addEventListener('click', () => openPicker(pk.key || 'red'));
document.addEventListener('click', e => { const b = e.target.closest('[data-space]'); if (b) setSpace(b.dataset.space); });
document.addEventListener('keydown', e => { if (e.key === 'Escape' && pk.key) closePicker(); });
addEventListener('resize', () => { pk.wheel = null; if (pk.key) drawPicker(); });

// --- rules panel ---
// How far a key sits from background (0%) to foreground (100%) in Dark, the position the system keeps.
function placedPct(k) {
  const src = srcPalette(tweaks.dark), g = groundOf(src);
  return ((toOkhsl(src[k])[0] - g.bg) / (g.fg - g.bg) * 100).toFixed(0);
}
function renderGrounds() {
  const src = srcPalette(tweaks.dark);
  $('r-system').checked = rules.system;
  for (const v of VARIANTS) {
    const g = groundFor(v, src), c = eff(v);
    for (const [k, val] of [['bg', g.bg], ['fg', g.fg]]) {
      const range = $(`g-${v}-${k}`), num = $(`g-${v}-${k}n`);
      range.value = val * 100; range.disabled = num.disabled = !rules.system;
      if (document.activeElement !== num) num.value = (val * 100).toFixed(1);
    }
    $(`g-${v}-mode`).textContent = modeOfGround(g);
    $(`g-${v}-chip`).style.background = c.accent;
    const hexIn = $(`g-${v}-accent`);
    hexIn.disabled = $(`g-${v}-chip`).disabled = !rules.system && v !== 'dark';
    if (document.activeElement !== hexIn) hexIn.value = c.accent;
    $(`g-${v}-reset`).hidden = v === 'dark' ? !tweaks.dark.accent : !tweaks[v].accent;
    $(`g-${v}-reset`).textContent = v === 'dark' ? `Reset to ${DATA.dark.colors.accent}` : 'Use Dark’s';
  }
}
function setGround(v, k, value) {
  const src = srcPalette(tweaks.dark), g = groundFor(v, src);
  setRule({ grounds: { ...rules.grounds, [v]: { ...g, [k]: clamp01(value) } } });
}
function setAccent(v, hex) {
  if (v === 'dark' ? hex === DATA.dark.colors.accent : hex === srcPalette(tweaks.dark).accent) delete tweaks[v].accent;
  else tweaks[v].accent = hex;
  paint();
  scheduleSave(v);
}
for (const v of VARIANTS) {
  for (const k of ['bg', 'fg']) {
    $(`g-${v}-${k}`).addEventListener('input', e => setGround(v, k, +e.target.value / 100));
    $(`g-${v}-${k}n`).addEventListener('input', e => { const x = parseFloat(e.target.value); if (Number.isFinite(x)) setGround(v, k, x / 100); });
  }
  $(`g-${v}-accent`).addEventListener('input', e => { const h = (e.target.value.startsWith('#') ? e.target.value : '#' + e.target.value).toLowerCase(); if (HEX.test(h)) setAccent(v, h); });
  $(`g-${v}-reset`).addEventListener('click', () => { delete tweaks[v].accent; paint(); scheduleSave(v); });
  // the picker edits the variant on show, so switch to this one first
  $(`g-${v}-chip`).addEventListener('click', () => { if (v !== variant) select(v); openPicker('accent'); });
}
$('r-system').addEventListener('change', e => setRule({ system: e.target.checked }));

// Reset the panel's values (not which rules are on): the numbers, every ground and every
// variant's accent. Asks for a second click, since the old values aren't kept.
let resetArmed = null;
$('r-reset').addEventListener('click', () => {
  const btn = $('r-reset');
  if (!resetArmed) {
    btn.textContent = 'Click again to reset';
    resetArmed = setTimeout(() => { resetArmed = null; btn.textContent = 'Reset to defaults'; }, 3000);
    return;
  }
  clearTimeout(resetArmed); resetArmed = null; btn.textContent = 'Reset to defaults';
  const accents = VARIANTS.filter(v => tweaks[v].accent);
  for (const v of accents) delete tweaks[v].accent;
  setRule({ ...RULE_VALUE_DEFAULTS, grounds: {} });
  for (const v of accents) scheduleSave(v);
  flash('Rule values reset');
});

function renderRules() {
  renderGrounds();
  $('r-neutral').checked = rules.neutral;
  $('r-hues').checked = rules.hues;
  $('r-muted').checked = rules.mutedFromSel;
  $('r-sel').checked = rules.selFromAccent;
  for (const [id, v, d, on] of [['r-red', rules.red, 1, rules.hues], ['r-split', rules.split, 1, rules.hues], ['r-selpct', rules.selPct, 1, rules.selFromAccent], ['r-depth', rules.lightDepth, 1, rules.system]]) {
    $(id).value = v; $(id).disabled = $(id + 'n').disabled = !on;
    if (document.activeElement !== $(id + 'n')) $(id + 'n').value = v.toFixed(d);
  }
  const c = eff(variant);
  $('r-hue-list').replaceChildren(...['red', 'orange', 'brown', 'yellow', 'green', 'cyan', 'blue', 'magenta'].map(k => {
    const h = rules.hues ? ruleHue(rules, k) : toOkhsl(c[k])[2];
    return el('span', { class: 'hue-chip' }, [el('i', { style: `background:${c[k]}` }), `${k} ${Number.isNaN(h) ? '–' : h.toFixed(1) + '°'}`]);
  }));
}
function setRule(patch) {
  Object.assign(rules, patch);
  if ((rules.hues || rules.system) && even.on) { even.on = false; preview = {}; }
  pk.hex = null;   // reload the picker's coordinates from the ruled colour
  paint();
  scheduleSave('rules');
}
$('r-neutral').addEventListener('change', e => setRule({ neutral: e.target.checked }));
$('r-hues').addEventListener('change', e => setRule({ hues: e.target.checked }));
$('r-muted').addEventListener('change', e => setRule({ mutedFromSel: e.target.checked }));
$('r-sel').addEventListener('change', e => setRule({ selFromAccent: e.target.checked }));
$('r-selpct').addEventListener('input', e => setRule({ selPct: +e.target.value }));
$('r-depth').addEventListener('input', e => setRule({ lightDepth: +e.target.value }));
$('r-red').addEventListener('input', e => setRule({ red: +e.target.value }));
$('r-split').addEventListener('input', e => setRule({ split: +e.target.value }));
for (const [id, lo, hi, key] of [['r-redn', 0, 360, 'red'], ['r-splitn', 0, 60, 'split'], ['r-selpctn', 0, 100, 'selPct'], ['r-depthn', 0, 150, 'lightDepth']])
  $(id).addEventListener('input', e => { const v = parseFloat(e.target.value); if (Number.isFinite(v)) setRule({ [key]: key === 'red' ? ((v % 360) + 360) % 360 : Math.min(hi, Math.max(lo, v)) }); });
function cleanRules(d) {
  const num = (x, lo, hi, dflt) => typeof x === 'number' && Number.isFinite(x) && x >= lo && x <= hi ? x : dflt;
  const grounds = {};
  for (const v of VARIANTS) {
    const g = d?.grounds?.[v];
    if (g && num(g.bg, 0, 1, null) !== null && num(g.fg, 0, 1, null) !== null) grounds[v] = { bg: g.bg, fg: g.fg };
  }
  return { system: d?.system === true, grounds, neutral: d?.neutral === true, hues: d?.hues === true, mutedFromSel: d?.mutedFromSel === true, selFromAccent: d?.selFromAccent === true, red: num(d?.red, 0, 360, RULE_VALUE_DEFAULTS.red), split: num(d?.split, 0, 60, RULE_VALUE_DEFAULTS.split), selPct: num(d?.selPct, 0, 100, RULE_VALUE_DEFAULTS.selPct), lightDepth: num(d?.lightDepth, 0, 150, RULE_VALUE_DEFAULTS.lightDepth) };
}

// --- toolbar and saving ---
let saveState = 'loading', saveError = '';
function setState(s, err = '') { saveState = s; saveError = err; renderTools(); }
function renderTools() {
  const n = changeCount(variant);
  const others = VARIANTS.filter(v => v !== variant && changeCount(v)).map(v => `${TITLES[v]} (${changeCount(v)})`);
  for (const b of document.querySelectorAll('[data-space]')) b.setAttribute('aria-pressed', b.dataset.space === space);
  const label = even.on ? 'Preview' : { loading: 'Connecting', saved: n ? 'Saved' : 'No changes', pending: 'Saving…', local: 'Not saved', readonly: 'View only', error: 'Not saved' }[saveState];
  const state = $('state');
  state.textContent = label;
  state.className = 'state' + (!even.on && (saveState === 'error' || saveState === 'local') ? ' err' : '');
  const lead = n ? `<strong>${n} ${n === 1 ? 'colour' : 'colours'} changed in ${TITLES[variant]}.</strong> ` : '';
  const ruleText = [rules.system && 'Mirage and Light derived from Dark', rules.neutral && 'neutral shades', rules.selFromAccent && `selection from accent (${rules.selPct}% of the way to its lightness)`, rules.mutedFromSel && 'muted from selection', rules.hues && `hue layout (red ${rules.red.toFixed(1)}°, yellow and orange ±${rules.split.toFixed(1)}° from brown)`].filter(Boolean);
  const tail = (others.length ? ` Also changed: ${others.join(', ')}.` : '') + (ruleText.length ? ` Rules on: ${ruleText.join(', ')}.` : '');
  const body = {
    loading: 'Click a swatch to open the picker, or edit a hex code.',
    saved: 'Click a swatch to open the picker, or edit a hex code. Changes save as you go, so Claude can read them back into the generator.',
    pending: 'Saving your changes so Claude can read them.',
    local: 'This view can’t reach the page’s storage, so changes stay in this tab. Use Copy changes and paste them to Claude.',
    readonly: 'You can try colours here, but you can’t save them to this page. Use Copy changes and paste them to Claude.',
    error: `Your last change didn’t save (${saveError}). Use Copy changes and paste them to Claude.`,
  }[saveState];
  $('summary').innerHTML = even.on ? `<strong>Previewing even hues in ${TITLES[variant]}.</strong> Nothing is saved until you press Apply in the picker.` : lead + body + tail;
  $('copy-changes').disabled = !VARIANTS.some(changeCount) && !rules.neutral && !rules.hues && !rules.mutedFromSel && !rules.selFromAccent && !rules.system;
  $('reset-all').disabled = !n || saveState === 'readonly';
}

const timers = {}, chains = {}, gens = {}, dirty = {};
function scheduleSave(v) {
  if (!db || readOnly) return;
  dirty[v] = true;
  gens[v] = (gens[v] || 0) + 1;
  setState('pending');
  clearTimeout(timers[v]);
  timers[v] = setTimeout(() => {
    const gen = gens[v], updated = new Date().toISOString();
    const body = v === 'rules' ? { ...rules, updated } : { colors: { ...tweaks[v] }, roles: { ...roleTweaks[v] }, updated };
    const write = () => db.doc('tweaks/' + v).set(body);
    // one write at a time per document
    chains[v] = (chains[v] || Promise.resolve()).then(() => write().catch(e =>
      e?.code === 'unavailable' ? new Promise(r => setTimeout(r, 800 + Math.random() * 800)).then(write) : Promise.reject(e)
    )).then(() => {
      if (gens[v] === gen) { dirty[v] = false; if (!Object.values(dirty).some(Boolean)) setState('saved'); }
    }, e => {
      dirty[v] = false;
      if (e?.code === 'invalid_argument' || e?.code === 'not_granted') { readOnly = true; setState('readonly'); }
      else setState('error', e?.message || e?.code || 'unknown error');
    });
  }, 450);
}

function setColor(key, hex) {
  if (even.on) { flash('Apply or discard the even-hues preview first'); return; }
  const v = variant;
  if (isRole(key)) {
    const o = okOffset(hex, eff(v)[ROLE_BASE[key]]), d = roleDefaults(v)[key];
    const same = Math.abs(o.dl - d.dl) < 5e-4 && Math.abs(o.ds - d.ds) < 5e-4 && Math.abs(o.dh - d.dh) < 0.05;
    if (same) delete roleTweaks[v][key]; else roleTweaks[v][key] = o;
  } else {
    tweaks[v][key] = hex;
    if (eff(v)[key] === baseline(v)[key]) delete tweaks[v][key];   // no different from the rules alone
  }
  paint();
  scheduleSave(v);
}
function select(v) {
  variant = v;
  if (even.on) { even.start = bestStart(HUES.map(k => sp().coords(base(v)['bright_' + k])[2])); computeEven(); }
  buildPalette();
  paint();
  try { localStorage.setItem('tetra-variant', v); } catch {}
}

// Stored docs come from whoever can write the page: keep only known keys with valid hex values.
function clean(colors, v) {
  const out = {};
  for (const [k, h] of Object.entries(colors || {}))
    if (KEYS.includes(k) && typeof h === 'string' && HEX.test(h.toLowerCase()) && h.toLowerCase() !== DATA[v].colors[k]) out[k] = h.toLowerCase();
  return out;
}
function cleanRoles(roles) {
  const out = {}, num = (x, lo, hi) => typeof x === 'number' && Number.isFinite(x) && x >= lo && x <= hi;
  for (const [r, o] of Object.entries(roles || {}))
    if (isRole(r) && o && num(o.dl, -1, 1) && num(o.ds, -1, 1) && num(o.dh, -180, 180)) out[r] = { dl: o.dl, ds: o.ds, dh: o.dh };
  return out;
}

$('reset-all').addEventListener('click', () => { tweaks[variant] = {}; roleTweaks[variant] = {}; paint(); scheduleSave(variant); });
$('copy-changes').addEventListener('click', e => {
  const lines = [
    ...(rules.neutral ? ['# Rule: neutral shades (backgrounds and foregrounds: grey at the same OKLab lightness)'] : []),
    ...(rules.selFromAccent ? [`# Rule: selection at accent's opposite OKHSL hue, its own saturation, OKHSL lightness ${rules.selPct}% of the way from black (white in Light) to accent's`] : []),
    ...(rules.mutedFromSel ? ['# Rule: muted takes selection\'s OKHSL hue and saturation at its own OKHSL lightness'] : []),
    ...(rules.system ? [`# Rule: every variant is Dark placed on its own ground (OKHSL lightness of background and foreground) with its own accent; hues keep Dark's distance from the background, ${rules.lightDepth}% of it on a light ground`, ...VARIANTS.map(v => { const g = groundFor(v, srcPalette(tweaks.dark)); return `#   ${v}: background ${(g.bg * 100).toFixed(1)}, foreground ${(g.fg * 100).toFixed(1)}, accent ${eff(v).accent}`; })] : []),
    ...(rules.hues ? [`# Rule: hue layout in OKHSL, red ${rules.red}°, brown ${(rules.red + 60) % 360}°, yellow +${rules.split}° and orange −${rules.split}° from brown, then 60° steps`] : []),
    ...(rules.neutral || rules.hues || rules.mutedFromSel || rules.selFromAccent || rules.system ? [''] : []),
  ].concat(VARIANTS.filter(changeCount).flatMap(v => [
    `# ${TITLES[v]} (themes/tetra-${v}/colors.toml)`,
    ...Object.entries(tweaks[v]).map(([k, h]) => `${k} = "${h}"  # was ${DATA[v].colors[k]}`),
    ...Object.entries(roleTweaks[v]).map(([r, o]) => `${r} = "${eff(v)[r]}"  # ${ROLE_BASE[r]} ${fmtOffset(o)} in OKHSL; ${defaultOwner(r)} is ${fmtOffset(roleDefaults(v)[r])}`), '',
  ]));
  copyText(lines.join('\n').trim(), e.currentTarget, 'Copied changes');
});

// --- copy helper and toast ---
const toast = $('toast');
let toastTimer;
function flash(msg) { toast.textContent = msg; toast.classList.add('show'); clearTimeout(toastTimer); toastTimer = setTimeout(() => toast.classList.remove('show'), 1600); }
function copyText(text, node, ok) {
  const fallback = () => { const r = document.createRange(); r.selectNodeContents(node); getSelection().removeAllRanges(); getSelection().addRange(r); flash('Couldn’t copy; selected instead'); };
  if (navigator.clipboard) navigator.clipboard.writeText(text).then(() => flash(ok), fallback); else fallback();
}
document.addEventListener('click', e => {
  const t = e.target.closest('[data-hex]');
  if (t) copyText(t.dataset.hex, t, `Copied ${t.dataset.hex}`);
});

// --- start ---
for (const v of VARIANTS) {
  const b = el('button', { 'data-v': v, 'aria-pressed': 'false' }, [el('span', { class: 'dot' }), TITLES[v].replace('Tetra ', '')]);
  b.addEventListener('click', () => select(v));
  $('seg').append(b);
}
let start;
try { start = localStorage.getItem('tetra-variant'); } catch {}
if (DATA[location.hash.slice(1)]) start = location.hash.slice(1);
if (!DATA[start]) {
  const t = document.documentElement.dataset.theme;
  start = t === 'light' || (!t && !matchMedia('(prefers-color-scheme: dark)').matches) ? 'light' : 'dark';
}
select(start);
{ // open the Neovim mock scrolled to its cursor line, as Neovim would be
  const pre = document.querySelector('.nv pre.code'), cur = pre?.querySelector('.ln.cur');
  if (cur) pre.scrollTop = cur.offsetTop - pre.offsetTop - pre.clientHeight / 3;
}

(async () => {
  db = window.claude?.use ? await window.claude.use('db') : null;
  if (!db) { setState('local'); return; }
  setState('saved');
  for (const v of VARIANTS) {
    db.doc('tweaks/' + v).onSnapshot(snap => {
      if (dirty[v] || snap.metadata.hasPendingWrites) return;
      const next = clean(snap.exists ? snap.data().colors : {}, v), nextRoles = cleanRoles(snap.exists ? snap.data().roles : {});
      if (JSON.stringify(next) === JSON.stringify(tweaks[v]) && JSON.stringify(nextRoles) === JSON.stringify(roleTweaks[v])) return;
      tweaks[v] = next;
      roleTweaks[v] = nextRoles;
      paint();
    }, e => setState('error', e?.message || e?.code || 'lost connection'));
  }
  db.doc('tweaks/rules').onSnapshot(snap => {
    if (dirty.rules || snap.metadata.hasPendingWrites) return;
    const next = cleanRules(snap.exists ? snap.data() : {});
    if (JSON.stringify(next) === JSON.stringify(rules)) return;
    Object.assign(rules, next);
    pk.hex = null;
    paint();
  }, e => setState('error', e?.message || e?.code || 'lost connection'));
})();
