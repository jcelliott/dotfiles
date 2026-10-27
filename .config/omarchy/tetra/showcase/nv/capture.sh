#!/bin/bash
# Captures real LazyVim (current Omarchy theme) showing FILE from line FIRST, one screen
# tall, with the cursor at CURSOR:COL and nv/diagnostics.json set as diagnostics. Neovim
# runs in FILE's parent's parent, so the status line shows a short path.
# Usage: nv/capture.sh FILE FIRST CURSOR COL LAST OUT   (run from showcase/)
file=$(realpath "$1") first=$2 cursor=$3 col=$4 last=$5 out=$6
diags=$(realpath nv/diagnostics.lua)
T="tmux -L tetracap -f /dev/null"
$T kill-server 2>/dev/null
$T new-session -d -x 160 -y $((last - first + 2)) -c "$(dirname "$(dirname "$file")")" -e COLORTERM=truecolor \
  "nvim '+set scrolloff=0' '+call cursor($first, 1)' '+normal! zt' '+call cursor($cursor, $col)' '+luafile $diags' '$file'"
$T set -as terminal-features ',*:RGB,*:usstyle' >/dev/null
for _ in $(seq 60); do $T capture-pane -p | grep -q 'NORMAL' && break; sleep 0.25; done
sleep 2.5
$T capture-pane -e -p > "$out"
$T kill-server
