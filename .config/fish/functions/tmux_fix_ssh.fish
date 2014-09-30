function tmux_fix_ssh --description 'print SSH_AUTH_SOCK from outer environment (eval)'
  # this should be used as `eval (tmux_fix_ssh)`
  echo "set -x SSH_AUTH_SOCK" (tmux show-environment | awk '/^SSH_AUTH_SOCK=/ { sub(/.*=/,""); print }')
end
