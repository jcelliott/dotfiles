# Builds tetra.html from template.html, script.js and tetra.json (from extract.py), with
# nv/tetra/swatch.py in the Neovim mock, drawn as LazyVim with the generated aether theme
# draws it, diagnostics from nv/diagnostics.json included. nv/check.py compares the mock
# with a capture of the real thing.
import html, json, os, re, subprocess

GENERATOR = os.path.expanduser('~/.config/omarchy/tetra/generate')
THEME = os.path.expanduser('~/.config/omarchy/themes/tetra-{}/neovim.lua')
SOURCE = 'nv/tetra/swatch.py'
LINES = open(SOURCE).read().rstrip('\n').split('\n')
CURSOR = next(i for i, l in enumerate(LINES, 1) if l.strip().startswith('def luminance'))
CURSOR_COL = len(LINES[CURSOR - 1]) - len(LINES[CURSOR - 1].lstrip())   # on the first character, as after ^
DIAGNOSTICS = {d['line']: d for d in json.load(open('nv/diagnostics.json'))}
# gitsigns marks: a changed line, two added lines and a deletion below a line
SIGNS = {30: ('vcs_modified', '▎'), 47: ('vcs_added', '▎'), 48: ('vcs_added', '▎'), 66: ('vcs_removed', '')}
DIGITS = len(str(len(LINES)))
GUTTER = 2 + DIGITS + 1 + 2   # diagnostic sign, number, space, git sign
# Severity: gutter icon, and the keys for the icon and underline, the message text and its tint.
# aether colours the error and info messages bright_red and bright_blue over their role tint.
SEVERITY = dict(ERROR=('', 'error', 'bright_red'), WARN=('', 'orange', 'orange'),
                INFO=('', 'tag', 'bright_blue'), HINT=('', 'bright_cyan', 'bright_cyan'))
# todo-comments keywords Tetra's sample uses: gutter icon and colour (TODO is DiagnosticInfo,
# NOTE is DiagnosticHint). The badge text is black or white, whichever contrasts more.
TODO_KEYWORDS = dict(TODO=('\uf00c', 'tag'), NOTE=('\uea74', 'bright_cyan'))
# aether's palette names for the colors.toml keys they carry
AETHER = dict(bg='background', fg='foreground', dark_bg='dark_background', darker_bg='darker_background',
              lighter_bg='lighter_background', dark_fg='dark_foreground', light_fg='light_foreground',
              bright_fg='bright_foreground')

def highlights():
    """Each syntax group in the generator's NEOVIM_HIGHLIGHTS as (page key, italic)."""
    block = open(GENERATOR).read().split('NEOVIM_HIGHLIGHTS = """\\\n', 1)[1].split('"""', 1)[0]
    out = {}
    for quoted, bare, spec in re.findall(r'^\s*(?:\["([^"]+)"\]|(\w+)) = \{ (.*) \},?$', block, re.M):
        fg = re.search(r'\bfg = ([cr])\.(\w+)', spec)
        if fg:
            out[quoted or bare] = (AETHER.get(fg[2], fg[2]) if fg[1] == 'c' else fg[2], 'italic = true' in spec)
    return out

def syntax():
    """Per-character page keys and italics, from Neovim's own treesitter highlighting
    under each generated theme (nv/dump.lua)."""
    hl, dumps = highlights(), []
    for v in ('dark', 'mirage', 'light'):
        out = f'nv/{v}.json'
        subprocess.run(['nvim', '--headless', '-u', 'NONE', '-l', 'nv/dump.lua', THEME.format(v),
                        SOURCE, '1', str(len(LINES)), out], check=True)
        d = json.load(open(out))
        roles = dict(re.findall(r'^\t(\w+) = "(#\w+)",$', open(THEME.format(v)).read(), re.M))
        values = {**{AETHER.get(k, k): h for k, h in d['colors'].items()}, **roles}
        for g, got in d['groups'].items():
            assert g in hl, f'{g} colours the sample but is not in NEOVIM_HIGHLIGHTS'
            key, italic = hl[g]
            assert values[key] == got['fg'] and italic == bool(got.get('italic')), (v, g, key, got)
        dumps.append(d)
    assert all(d['rows'] == dumps[0]['rows'] for d in dumps), 'variants highlight the sample differently'
    return [[hl[g] if g else ('foreground', False) for g in row] for row in dumps[0]['rows']]

def guides():
    """snacks.nvim indent guides as {(line index, col): in_scope}: one per indent level, and the
    cursor's scope (the block that starts on the cursor line, to its last non-blank line) in
    accent. A blank line takes the shallower of its neighbours, one level deeper when they
    differ and neither is at the top."""
    depth = [None if not l.strip() else (len(l) - len(l.lstrip())) // 4 for l in LINES]
    for i, d in enumerate(depth):
        if d is None:
            prev = next((x for x in reversed(depth[:i]) if x is not None), 0)
            nxt = next((x for x in depth[i + 1:] if x is not None), 0)
            depth[i] = min(prev, nxt) + (prev != nxt and min(prev, nxt) > 0)
    top = depth[CURSOR - 1]
    end = next((i for i in range(CURSOR, len(LINES)) if depth[i] <= top), len(LINES))
    while not LINES[end - 1].strip(): end -= 1   # the scope stops at its last non-blank line
    return {(r, 4 * k): k == top and CURSOR <= r < end for r, d in enumerate(depth) for k in range(d)}

def cell(ch, fg, bold=False, italic=False, bg=None, curl=None):
    return [ch, fg, bold, italic, bg, curl]

def model():
    """The editor as rows of cells [char, fg key, bold, italic, background, undercurl key]; a
    background is a key, or key/10 for that colour at 10% over the background."""
    syn, ig = syntax(), guides()
    rows = []
    for r, line in enumerate(LINES):
        n, diag = r + 1, DIAGNOSTICS.get(r + 1)
        num = ('orange', True) if n == CURSOR else ('muted', False)
        todo = next(((m, *TODO_KEYWORDS[m[1]]) for m in re.finditer(r'\b(%s)\s*:' % '|'.join(TODO_KEYWORDS), line)
                     if syn[r][m.start()] == ('muted', True)), None)   # in a comment
        icon = (SEVERITY[diag['severity']][0], SEVERITY[diag['severity']][1]) if diag else todo[1:] if todo else None
        cells = [cell(icon[0], icon[1]), cell(' ', 'foreground')] if icon else [cell(' ', 'foreground')] * 2
        cells += [cell(ch, *num) for ch in f'{n:>{DIGITS}} ']
        sign = SIGNS.get(n)
        cells += [cell(sign[1], sign[0]), cell(' ', 'foreground')] if sign else [cell(' ', *num)] * 2
        for x, ch in enumerate(line.ljust(max((c + 1 for rr, c in ig if rr == r), default=0))):
            if (r, x) in ig:
                cells.append(cell('│', 'accent' if ig[r, x] else 'muted'))
            else:
                key, italic = syn[r][x] if x < len(syn[r]) else ('foreground', False)
                cells.append(cell(ch, key, False, italic))
        if todo:   # badge over the space before the keyword through the colon, then the colour to the end
            m, _, key = todo
            for x in range(m.start() - 1, len(line)):
                c = cells[GUTTER + x]
                if x < m.end(): c[2], c[4] = True, key
                c[1] = f'ink/{key}' if x < m.end(1) else key
        if diag:
            _, sign_key, text_key = SEVERITY[diag['severity']]
            for x in range(diag['col'], diag['end_col']):
                cells[GUTTER + x][5] = sign_key
            cells += [cell(' ', 'foreground')] * 5 + [cell(ch, text_key, bg=sign_key + '/10') for ch in '● ' + diag['message']]
        if n == CURSOR:   # foot's block cursor
            cells[GUTTER + CURSOR_COL][1] = 'cursor'
        rows.append(cells)
    return rows

def status():
    """lualine's runs as [text, fg key, bg key, bold]; powerline glyphs become CSS shapes."""
    counts = {s: sum(d['severity'] == s for d in DIAGNOSTICS.values()) for s in SEVERITY}
    diags = [[f'{SEVERITY[s][0]} {n} ', SEVERITY[s][1], 'background', False] for s, n in counts.items() if n]
    if diags: diags[0][0] = ' ' + diags[0][0]
    pos = f' {CURSOR * 100 // len(LINES)}% {CURSOR:>3}:{CURSOR_COL + 1:<2} '
    return ([[' NORMAL ', 'darker_background', 'yellow', True], ['', 'yellow', 'background', False]] + diags +
            [['', 'foreground', 'background', False]] * bool(diags) +
            [[' \U000f0320 ', 'orange', 'background', False], [' tetra/swatch.py', 'foreground', 'background', False],
             ['', 'foreground', 'background', False],   # fill
             ['  17 ', 'accent', 'background', False], ['', 'dark_background', 'background', False],
             [pos, 'yellow', 'dark_background', False], ['', 'yellow', 'dark_background', False],
             ['  22:04 ', 'darker_background', 'yellow', True]])

def render(rows):
    out = []
    for r, cells in enumerate(rows):
        runs, i = [], 0
        while i < len(cells):
            j = i
            while j < len(cells) and cells[j][1:] == cells[i][1:]: j += 1
            _, fg, bold, italic, bg, curl = cells[i]
            cls = ['cursor' if fg == 'cursor' else f't-{fg.replace("/", "-")}'] + ['bd'] * bold + ['it'] * italic + \
                  ([f'bg-{bg.replace("/", "-")}'] if bg else []) + [f'cu-{curl}'] * bool(curl)
            runs.append(f'<span class="{" ".join(cls)}">{html.escape("".join(c[0] for c in cells[i:j]))}</span>')
            i = j
        out.append(f'<span class="ln{" cur" if r + 1 == CURSOR else ""}">{"".join(runs)}</span>')
    return ''.join(out)

def render_status(runs):
    out = []
    for text, fg, bg, bold in runs:
        if text in ('', '', ''):
            kind = {'': 'sep', '': 'sep l', '': 'sep thin'}[text]
            out.append(f'<span class="{kind}" style="--over: var(--c-{fg}); --under: var(--c-{bg})"></span>')
        else:
            cls = 'fill' if not text else 'path' if '/' in text else ''
            style = f'color: var(--c-{fg}); background: var(--c-{bg})' + '; font-weight: 700' * bold
            out.append(f'<span class="{cls}" style="{style}">{html.escape(text)}</span>')
    return ''.join(out)

rows, runs = model(), status()
json.dump(dict(cursor=CURSOR, gutter=GUTTER, signs=sorted(SIGNS), rows=rows, status=runs), open('nv/model.json', 'w'))
keys = {c[1] for row in rows for c in row} - {'cursor'}
tints = {c[4] for row in rows for c in row} - {None}
curls = {c[5] for row in rows for c in row} - {None}
css = ' '.join([f'.nv .t-{k.replace("/", "-")}{{color:var(--{k.replace("/", "-") if k.startswith("ink/") else "c-" + k})}}' for k in sorted(keys)] +
               [f'.nv .bg-{k.replace("/", "-")}{{background:' + (f'color-mix(in srgb,var(--c-{k[:-3]}) 10%,var(--c-background))' if k.endswith('/10') else f'var(--c-{k})') + '}' for k in sorted(tints)] +
               [f'.nv .cu-{k}{{text-decoration-color:var(--c-{k})}}' for k in sorted(curls)])

t = open('template.html').read()
js = open('script.js').read().replace('__DATA__', open('tetra.json').read().strip())
t = re.sub(r'<script>.*</script>', lambda m: '<script>\n' + js + '</script>', t, flags=re.S)
t = (t.replace('/*__NVIM_CSS__*/', css).replace('__NVIM_CODE__', render(rows))
      .replace('__NVIM_STATUS__', render_status(runs)).replace('__NVIM_GUTTER__', str(GUTTER)))
open('tetra.html', 'w').write(t)
