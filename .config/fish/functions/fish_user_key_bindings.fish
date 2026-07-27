function fish_user_key_bindings --description "User key bindings for fish"
  fish_vi_key_bindings

  # fzf widgets, defined by the integration sourced in config.fish:
  #   Ctrl-R  fuzzy history search
  #   Ctrl-T  paste selected paths onto the command line
  #   Alt-C   cd into a selected directory
  # The integration also binds shift-tab to fzf completion; erase it so
  # tab-completion behaviour is left untouched.
  bind \cr fzf-history-widget
  bind -M insert \cr fzf-history-widget
  bind \ct fzf-file-widget
  bind -M insert \ct fzf-file-widget
  bind \ec fzf-cd-widget
  bind -M insert \ec fzf-cd-widget
  bind -e shift-tab
  bind -M insert -e shift-tab

  # normal mode
  bind -m insert \n execute
  bind \cl 'clear; commandline -f repaint'
  bind -e home
  bind home beginning-of-line
  bind H beginning-of-line
  bind L end-of-line
  bind \es prepend_sudo
  bind $argv f1 __fish_man_page

  # insert mode
  bind \cl 'clear; commandline -f repaint'
  bind -e -M insert home
  bind -M insert home beginning-of-line
  bind -M insert \cw beginning-of-line
  bind -M insert \ce end-of-line
  bind -M insert \cf accept-autosuggestion
  bind -M insert \cg suppress-autosuggestion
  bind -M insert \es prepend_sudo
  bind -M insert $argv f1 __fish_man_page
  bind -M insert \ej backward-word
  bind -M insert \ek forward-word
  bind -M insert \eh backward-char
  bind -M insert \el forward-char
  bind -M insert \eH beginning-of-line
  bind -M insert \eL end-of-line

  # prompt_edit mode
  bind -e ctrl-p
  bind -M default -m prompt_edit ctrl-p force-repaint
  bind -e -M insert ctrl-p
  bind -M insert -m prompt_edit ctrl-p force-repaint

  bind -M prompt_edit -m insert g toggle-git-prompt

  bind -M prompt_edit -m insert ctrl-c force-repaint
  bind -M prompt_edit -m insert escape force-repaint
  bind -M prompt_edit -m insert enter force-repaint

end

