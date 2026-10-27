# Compares the Neovim mock (nv/model.json, written by build.py) with real LazyVim in a
# tmux capture, cell by cell and run by run on the status line, using the generated Tetra
# Dark colours. Needs Tetra Dark as the current Omarchy theme.
# Run from showcase/: python3 nv/check.py
import json, os, re, subprocess, sys
sys.path.insert(0, os.path.dirname(__file__))
from ansi import parse

m = json.load(open('nv/model.json'))
cursor, gutter, rows = m['cursor'], m['gutter'], m['rows']
col = next(x for x, c in enumerate(rows[cursor - 1]) if c[1] == 'cursor') - gutter + 1
subprocess.run(['nv/capture.sh', 'nv/tetra/swatch.py', '1', str(cursor), str(col), str(len(rows)), 'nv/tall.ansi'], check=True)
screen = parse('nv/tall.ansi')

lua = open(os.path.expanduser('~/.config/omarchy/themes/tetra-dark/neovim.lua')).read()
alias = dict(bg='background', fg='foreground', dark_bg='dark_background', darker_bg='darker_background',
             lighter_bg='lighter_background', dark_fg='dark_foreground', light_fg='light_foreground', bright_fg='bright_foreground')
hexes = {**{alias.get(k, k): h for k, h in re.findall(r'^\t\t\t\t(\w+) = "(#\w+)",$', lua, re.M)},
         **dict(re.findall(r'^\t(\w+) = "(#\w+)",$', lua, re.M))}
blend = lambda a, t, b: '#' + ''.join('%02x' % int(t * int(a[i:i + 2], 16) + (1 - t) * int(b[i:i + 2], 16) + 0.5) for i in (1, 3, 5))
lum = lambda h: sum(w * ((x / 255) / 12.92 if x / 255 <= 0.04045 else ((x / 255 + 0.055) / 1.055) ** 2.4)
                   for w, x in zip((0.2126, 0.7152, 0.0722), (int(h[i:i + 2], 16) for i in (1, 3, 5))))
ratio = lambda a, b: (max(lum(a), lum(b)) + 0.05) / (min(lum(a), lum(b)) + 0.05)
hexes.update({'ink/' + k: '#ffffff' if ratio(h, '#ffffff') > ratio(h, '#000000') else '#000000' for k, h in list(hexes.items())})
cursorline = blend(hexes['foreground'], 0.2, hexes['background'])

bad = 0
def expect(where, got, want):
    global bad
    if got != want:
        bad += 1
        if bad <= 20: print(where, 'real', got, 'mock', want)

for r, cells in enumerate(rows):
    n = r + 1
    real = [(ch, fg, bg, a, ul) for text, fg, bg, a, ul in screen[r] for ch in text]
    for x, (ch, key, bold, italic, tint, curl) in enumerate(cells):
        if n in m['signs'] and x in (gutter - 2, gutter - 1): continue   # the real file has no git changes
        if key == 'cursor': continue                                      # foot draws the cursor, not Neovim
        rch, rfg, rbg, ra, rul = real[x] if x < len(real) else (' ', None, None, '', None)
        want_bg = blend(hexes[tint[:-3]], 0.1, hexes['background']) if tint and tint.endswith('/10') else hexes[tint] if tint else cursorline if n == cursor and x >= gutter else None
        expect(f'{n}:{x} {ch!r} bg', rbg, want_bg)
        expect(f'{n}:{x} {ch!r} curl', (rul, 'c' in ra), (hexes[curl], True) if curl else (None, False))
        if ch == ' ' and rch == ' ': continue                             # a blank's own colour isn't visible
        expect(f'{n}:{x} {ch!r}', (rch, rfg, 'b' in ra, 'i' in ra), (ch, hexes[key], bold, italic))
    if ''.join(ch for ch, *_ in real[len(cells):]).strip():
        expect(f'{n} extra', ''.join(ch for ch, *_ in real[len(cells):]), '')

# the status line, runs of one colour merged on both sides; text compared without the fill
def merged(runs):
    out = []
    for text, fg, bg, bold in runs:
        if out and out[-1][1:] == [fg, bg, bold]: out[-1][0] += text
        else: out.append([text, fg, bg, bold])
    return [[t.strip(), fg, bg, bold] for t, fg, bg, bold in out]
real = merged([(t, fg, bg, 'b' in a) for t, fg, bg, a, _ in screen[len(rows)]])
mock = merged([(t, hexes[fg], hexes[bg], bold) for t, fg, bg, bold in m['status']])
for i, (rr, mm) in enumerate(zip(real, mock)):
    if re.fullmatch(r'\S+ \d\d:\d\d', mm[0]): rr[0] = mm[0]   # the clock
    expect(f'status run {i}', rr, mm)
expect('status runs', len(real), len(mock))
print('rows', len(rows), 'mismatches', bad)
sys.exit(1 if bad else 0)
