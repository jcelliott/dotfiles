function fish_user_key_bindings --description "User key bindings for fish"
  fish_vi_key_bindings

  # normal mode
  bind -m insert \n execute
  bind \cl clear 'commandline ""' execute
  bind -e -k home
  bind -k home beginning-of-line
  bind H beginning-of-line
  bind L end-of-line

  # insert mode
  bind -M insert \cl clear 'commandline ""' execute
  bind -e -M insert -k home
  bind -M insert -k home beginning-of-line
  bind -M insert \cw beginning-of-line
  bind -M insert \ce end-of-line
  bind -M insert \cf accept-autosuggestion
  bind -M insert \cg suppress-autosuggestion

end

