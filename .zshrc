#    ___       __
#   /_  / ___ / /  ________
#  _ / /_(_-</ _ \/ __/ __/
# (_)___/___/_//_/_/  \__/
#
# Joshua Elliott
# --------------------------

# colorized output
function cinfo() {
  # echo -e "\x1b[34m$1\x1b[0m" # blue
  echo -e "\x1b[32m$1\x1b[0m" # green
}
function cwarn() {
  echo -e "\x1b[33m$1\x1b[0m"
}
function cerror() {
  echo -e "\x1b[31m$1\x1b[0m"
}

### oh-my-zsh setup ###
# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Look in ~/.oh-my-zsh/themes/
ZSH_THEME="afowler"

# Comment this out to enable weekly auto-update checks
DISABLE_AUTO_UPDATE="true"

# Plugins (~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(brew node npm osx ruby rvm screen)

source $ZSH/oh-my-zsh.sh

### zsh options ###
# GLOBDOTS lets files beginning with a . be matched without explicitly specifying the dot
setopt globdots

# HISTIGNOREDUPS prevents the current line from being saved in the history if it is the same as the previous one
setopt histignoredups

# CORRECT turns on spelling correction for commands
unsetopt correct
# CORRECTALL turns on spelling correction for all arguments.
unsetopt correctall

# Use vi style bindings
#bindkey -v

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

### Editor ###
export EDITOR='vim -f'

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
      cwarn "You should install pacman-color (AUR)"
    fi
  fi
fi

alias df='df -h'
alias no='ls' # for dvorak
alias vimconf='vim ~/.vimrc'
alias zshconf='vim ~/.zshrc'

# Git aliases
alias gst='git status'
alias gc='git commit -v'
alias glg='git log --stat --graph --decorate'
alias glgs='git log --stat --graph --decorate --max-count=3'
alias ga='git add'
alias gsa='git submodule add'
alias gsi='git submodule init'
alias gsu='git submodule update'
alias gsuu='git submodule foreach git pull origin master'
alias gcm='git checkout master'
alias gch='git checkout'
alias gl='git pull'
alias gs='git push'
alias gpnp='git pull;git push'

# Use MacVim's build of vim if it exists on the system
# Using custom compiled vim instead now
# command -v mvim >/dev/null 2>&1
# if [ $? -eq 0 ]; then
#   echo "Vim: Using macvim build"
#   alias vim='/usr/local/Cellar/macvim/7.3-64/MacVim.app/Contents/MacOS/Vim'
# fi

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

### Fix git autocompletion ###
# from: <http://talkings.org/post/5236392664/zsh-and-slow-git-completion>
__git_files() {
  _wanted files expl 'local files' _files
}

### Local customizations ###
if [ -f "$HOME/.zshrc.local" ]; then
  cinfo "loading .zshrc.local"
  source "$HOME/.zshrc.local" ]
fi


### Start in home directory and Confirm load ###
# cd $HOME
cinfo "energize!"

