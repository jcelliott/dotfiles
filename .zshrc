#    ___       __
#   /_  / ___ / /  ________
#  _ / /_(_-</ _ \/ __/ __/
# (_)___/___/_//_/_/  \__/
#
# Joshua Elliott
# --------------------------

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Look in ~/.oh-my-zsh/themes/
ZSH_THEME="afowler"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Plugins (~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(git brew node npm osx ruby rvm screen)

source $ZSH/oh-my-zsh.sh

### Check OS ###
platform='unknown'
case `uname` in
  Darwin)
    platform=mac
    ;;
  Linux)
    platform=linux
    ;;
esac
echo "Operating System:   "$platform

### Path ###
PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin:/usr/texbin
if [ -d "$HOME/.bin" ]; then
  PATH=$HOME/.bin:$PATH
fi
export PATH

### Editor ###
export EDITOR='vim -f'

### Aliases ###
if [[ $platform == 'mac' ]]; then
  alias ls='gls --color=auto'
  alias ll='gls -lah --color=auto'
  alias la='gls -a --color=auto'

elif [[ $platform == 'linux' ]]; then
  alias ls='ls --color=auto'
  alias ll='ls -lah --color=auto'
  alias la='ls -a --color=auto'
fi

alias no='ls' # for dvorak
alias vimconf='vim ~/.vimrc'
alias zshconf='vim ~/.zshrc'

# this is not the correct way to do this, just more convenient right now (put in ~/.rspec)
alias rspec='rspec --color --format nested' 

# Use MacVim's build of vim if it exists on the system
command -v mvim >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "Vim: Using macvim build"
  alias vim='/usr/local/Cellar/macvim/7.3-64/MacVim.app/Contents/MacOS/Vim'
fi

### directory colors on linux (for using solarized color scheme) ###
if [ -e "$HOME/.config/.dircolors" ]; then
  #echo "using .dircolors"
  if [[ $platform == 'mac' ]]; then
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

### Confirm load ###
echo "energize!"

