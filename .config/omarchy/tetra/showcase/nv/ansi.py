# Parses a tmux `capture-pane -e` dump into runs of (text, fg, bg, attrs, underline colour)
# per row. attrs holds b (bold), i (italic), u (underline) and c (undercurl).
import re, sys
def parse(path):
    rows = []
    for line in open(path).read().split('\n'):
        fg = bg = ul = None; attrs = set(); runs = []
        for esc, text in re.findall(r'\x1b\[([0-9;:]*)m|([^\x1b]+)', line):
            if text: runs.append((text, fg, bg, ''.join(sorted(attrs)), ul)); continue
            p = (esc or '0').split(';')
            i = 0
            while i < len(p):
                sub = [int(x or 0) for x in p[i].split(':')]
                n = sub[0]
                if n in (38, 48, 58):
                    if len(sub) > 1: rgb = sub[-3:]                       # 58:2::r:g:b
                    else: rgb = [int(x) for x in p[i + 2:i + 5]]; i += 4   # 58;2;r;g;b
                    h = '#%02x%02x%02x' % tuple(rgb)
                    if n == 38: fg = h
                    elif n == 48: bg = h
                    else: ul = h
                elif n == 0: fg = bg = ul = None; attrs = set()
                elif n == 39: fg = None
                elif n == 49: bg = None
                elif n == 59: ul = None
                elif n == 1: attrs.add('b')
                elif n == 3: attrs.add('i')
                elif n == 4: attrs.discard('u'); attrs.discard('c'); attrs.add({0: '', 1: 'u', 3: 'c'}.get(sub[1], 'u') if len(sub) > 1 else 'u'); attrs.discard('')
                elif n in (22, 23, 24): attrs -= {22: {'b'}, 23: {'i'}, 24: {'u', 'c'}}[n]
                i += 1
        rows.append(runs)
    return rows
if __name__ == '__main__':
    rows = parse(sys.argv[1])
    for r in sys.argv[2:]:
        print(r, rows[int(r)])
