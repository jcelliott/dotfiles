function fish_user_key_bindings --description "User key bindings for fish"
  fish_vi_key_bindings

  # reverse search (https://github.com/jbonjean/re-search)
  bind \cr re_search
  bind -M insert \cr re_search

  # normal mode
  bind -m insert \n execute
  bind \cl clear 'commandline ""' execute
  bind -e -k home
  bind -k home beginning-of-line
  bind H beginning-of-line
  bind L end-of-line
  bind \es prepend_sudo
  bind $argv -k f1 __fish_man_page

  # insert mode
  bind -M insert \cl clear 'commandline ""' execute
  bind -e -M insert -k home
  bind -M insert -k home beginning-of-line
  bind -M insert \cw beginning-of-line
  bind -M insert \ce end-of-line
  bind -M insert \cf accept-autosuggestion
  bind -M insert \cg suppress-autosuggestion
  bind -M insert \es prepend_sudo
  bind -M insert $argv -k f1 __fish_man_page
  bind -M insert \ej backward-word
  bind -M insert \ek forward-word
  bind -M insert \eh backward-char
  bind -M insert \el forward-char
  bind -M insert \eH beginning-of-line
  bind -M insert \eL end-of-line

end

