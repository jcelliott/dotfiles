import json, runpy, os
g = runpy.run_path(os.path.expanduser('~/.config/omarchy/tetra/generate'), run_name='tetra_gen')
out = {}
for name, v in g['VARIANTS'].items():
    c = g['palette'](v)
    b = v['base24']
    if v['mode'] == 'light':
        dark_bg, darker_bg = v['sunk'], g['mix'](v['sunk'], b['b05'], 0.08)
    else:
        dark_bg, darker_bg = sorted([b['b10'], b['b11']], key=lambda h: -g['oklab'](h)[0])
    src = dict(background=b['b00'], dark_background=dark_bg, darker_background=darker_bg,
               lighter_background=b['b01'], foreground=b['b05'], dark_foreground=b['b04'],
               light_foreground=b['b06'], bright_foreground=b['b07'],
               selection=v['selection'] if isinstance(v['selection'], str) else g['over'](*v['selection']), muted=v['gray'])
    status = '#%02x%02x%02x' % tuple(int(x*0.97+y*0.03+0.5) for x, y in zip(g['rgb'](c['lighter_background']), g['rgb'](c['foreground'])))
    theme, _ = g['theme_palette'](name)   # what the generator writes, roles included
    out[name] = dict(mode=v['mode'], colors=c, source=src, status=status, theme={**theme, **g['roles'](theme)},
                     paseo=g['paseo_colors'](v['mode'], c),
                     wall=['#ffffff', c['dark_background']] if v['mode']=='light' else [g['lighten'](c['background'], 0.06), c['background']],
                     contrast={k: round(g['contrast'](h, c['background']), 2) for k, h in c.items()})
print(json.dumps(out))
