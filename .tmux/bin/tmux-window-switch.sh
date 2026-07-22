#!/usr/bin/env bash
# Fuzzy switch between windows in the current session.
# Zero-pads the window index so titles line up regardless of index width.
# tmux resolves a zero-padded target (e.g. "sess:03") the same as "sess:3".
set -euo pipefail

tmux list-windows -F '#{session_name}:#{window_index} #{window_name}' \
  | awk '{
      c = index($0, ":")            # session / index boundary
      sp = index($0, " ")           # index / name boundary
      printf "%s:%02d %s\n", substr($0, 1, c-1), substr($0, c+1, sp-c-1), substr($0, sp+1)
    }' \
  | fzf --reverse --prompt 'win> ' --nth 2.. \
  | cut -d' ' -f1 \
  | xargs -r tmux switch-client -t
