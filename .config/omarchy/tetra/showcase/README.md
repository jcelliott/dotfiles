# Tetra showcase

An interactive page for tuning Tetra: the palette with an OKLCH, HSL and OKHSL
picker, the theme rules and grounds that derive Mirage and Light from Dark, and
a desktop mock whose Neovim window is drawn as LazyVim draws it.

It is published as a private claude.ai artifact:
https://claude.ai/artifact/9wi4SZPyLRicRYfPKWi2Wb

Edits made on the page save to its database: the `tweaks` collection holds a
document per variant (`dark`, `mirage`, `light`, each with `colors` and `roles`)
and `rules`. Claude reads them back and copies the ones to keep into
`../generate`, then rebuilds and republishes the page to the same URL.

## Build

```
python3 extract.py > tetra.json   # the generator's palettes
python3 build.py                  # writes tetra.html
```

`build.py` runs Neovim headless on `nv/tetra/swatch.py` with each generated
theme, so regenerate the themes first when the generator changes.

## Checks

```
node check-derive.mjs   # colour maths, the rules, and that the generator matches the page
python3 nv/check.py     # the Neovim mock against real LazyVim in tmux; needs tetra-dark active
```

## Files

- `template.html`: markup and CSS; `script.js`: everything the page does.
- `nv/`: the Neovim mock. `swatch.py` is the sample file and `diagnostics.json`
  the diagnostics shown on it; `dump.lua` records Neovim's highlight groups and
  `capture.sh` captures real LazyVim for `check.py`.
