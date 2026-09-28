# .zshrc

setopt globdots histignoredups
unsetopt correct correctall
# Pass unmatched globs through literally (like bash) in Claude Code sessions only.
[[ -n $CLAUDECODE ]] && setopt nonomatch

export EDITOR=vim
[[ -d $HOME/bin ]] && path=($HOME/bin $path)

if [[ -o interactive ]]; then
  autoload -Uz compinit && compinit
  bindkey -e
  bindkey '^ ' up-line-or-search
  bindkey '^B' beginning-of-line

  # macOS gets GNU coreutils from Homebrew with a g prefix.
  [[ $OSTYPE == darwin* ]] && g=g || g=
  [[ -f ~/.config/.dircolors ]] && eval "$(${g}dircolors ~/.config/.dircolors)"
  alias ls="${g}ls --color=auto" ll="${g}ls -lah --color=auto" la="${g}ls -a --color=auto"
  unset g
fi
