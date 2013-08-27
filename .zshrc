#    ___       __
#   /_  / ___ / /  ________
#  _ / /_(_-</ _ \/ __/ __/
# (_)___/___/_//_/_/  \__/
#
# Joshua Elliott
#
# TODO:
#   - Move from oh-my-zsh to just antigen
# --------------------------

# colorized output
function cinfo() {
  echo -e "\x1b[32m$1\x1b[0m" # green
}
function cwarn() {
  echo -e "\x1b[33m$1\x1b[0m" # yellow
}
function cerror() {
  echo -e "\x1b[31m$1\x1b[0m" # red
}

### antigen ###
ZSH_CUSTOM="$HOME/.zsh"
ADOTDIR="$HOME/.zsh"
source "$HOME/.zsh/plugins/antigen/antigen.zsh"

# Bundles
antigen use oh-my-zsh
antigen bundle tmux
antigen bundle gitfast
antigen bundle ruby
antigen bundle python
antigen bundle golang

if [[ $platform == 'darwin' ]]; then
  antigen bundle osx
  antigen bundle brew
fi

antigen bundle zsh-users/zsh-syntax-highlighting

# Theme
antigen theme afowler

antigen apply

# TODO: move this to a more appropriate place
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}*%{$fg[yellow]%}"

### zsh options ###
# GLOBDOTS lets files beginning with a . be matched without explicitly specifying the dot
setopt globdots
# HISTIGNOREDUPS prevents the current line from being saved in the history if it is the same as the previous one
setopt histignoredups
# TODO: look into getting corrections working better
# CORRECT turns on spelling correction for commands
unsetopt correct
# CORRECTALL turns on spelling correction for all arguments.
unsetopt correctall

# Use vi style bindings
#bindkey -v
# use <C-space> like up arrow
bindkey '^ ' up-line-or-search

### Check OS ###
platform='unknown'
case `uname` in
  Darwin)
    platform='darwin'
    ;;
  Linux)
    platform='linux'
    ;;
esac

# Determine the specific linux distro
distro=''
if [ $platform = 'linux' ]; then
  if [ -f /etc/debian_version ]; then
    distro='debian'
  elif [ -f /etc/arch-release ]; then
    distro='arch'
  else
    distro='unknown'
  fi
fi
cinfo "Operating System: $platform $distro"

### Path ###
PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin:/usr/texbin
if [ -d "$HOME/bin" ]; then
  PATH=$HOME/bin:$PATH
fi
export PATH

### Term ###
export TERM=xterm-256color

### Editor ###
export EDITOR='vim -f'

### Use vim for man pager ###
function vman {
  vim -MRn -c 'set ft=man nomod nolist nonumber' \
    -c 'map q :q<CR>' \
    -c 'map <SPACE> <C-D>' \
    -c 'map b <C-U>' \
    -c 'nmap K :Man <C-R>=expand(\\\"<cword>\\\")<CR><CR>' \
    =(/usr/bin/man $* | col -bx)
    # zsh process substitution: =(...) is replaced with the name of a file containing its output
    # this is not the same as <(...) which creates a named pipe (FIFO) instead
}
alias man='vman'

### Aliases ###
if [[ $platform == 'darwin' ]]; then
  # Using GNU coreutils
  alias ls='gls --color=auto'
  alias ll='gls -lah --color=auto'
  alias la='gls -a --color=auto'
  alias ql='quick-look'

elif [[ $platform == 'linux' ]]; then
  alias ls='ls --color=auto'
  alias ll='ls -lah --color=auto'
  alias la='ls -a --color=auto'
  if [[ $distro == 'arch' ]]; then
    if [ -f "/usr/bin/pacman-color" ]; then
      alias pacman='pacman-color'
    else
      # cwarn "You should install pacman-color (AUR)"
    fi
  fi
fi

alias df='df -h'
# alias no='ls' # for dvorak
alias vimconf='vim ~/.vimrc'
alias zshconf='vim ~/.zshrc'

# Git aliases
# TODO: move these to real git aliases?
alias gst='git status'
alias gc='git commit -v'
alias glg='git log --all --stat --graph --decorate'
alias glgo='git log --all --graph --decorate --oneline'
alias glgs='git log --all --stat --graph --decorate --max-count=3'
alias ga='git add'
alias gsa='git submodule add' # gsa <repo> <directory>
alias gsi='git submodule init'
alias gsu='git submodule update'
alias gsuu='git submodule foreach git pull origin master'
alias gcm='git checkout master'
alias gch='git checkout'
alias gcb='git checkout -b'
alias gl='git pull'
alias gs='git push'
alias gpp='git pull;git push'
alias gf='git diff'
alias gba='git branch -a'

# turn off globbing for rake commands (rake task[arg] breaks)
alias rake="noglob rake"

# Use hub (github extensions for git) if it's installed
command -v hub >/dev/null 2>&1
if [ $? -eq 0 ]; then
  eval "$(hub alias -s)"
  # alias git='hub'
else
  cwarn "You should install hub (defunkt.io/hub)"
fi

### directory colors on linux (for using solarized color scheme) ###
if [ -f "$HOME/.config/.dircolors" ]; then
  #echo "using .dircolors"
  if [[ $platform == 'darwin' ]]; then
    eval `gdircolors $HOME/.config/.dircolors`
  elif [[ $platform == 'linux' ]]; then
    eval `dircolors ~/.config/.dircolors`
  fi
fi

### Ruby ###
if [ -d "$HOME/.rvm" ]; then
  #echo "Set up ruby stuff"
  PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
fi

### Local customizations ###
if [ -f "$HOME/.zshrc.local" ]; then
  cinfo "loading .zshrc.local"
  source "$HOME/.zshrc.local" ]
fi

### Start in home directory and Confirm load ###
# cd $HOME
cinfo "energize!"

