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

### Path ###
PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin:/usr/texbin
if [ -d "$HOME/.scripts" ]; then
  PATH=$HOME/.scripts:$PATH
fi
export PATH

### Editor ###
export EDITOR='vim -f'

### Aliases ###
alias ll='ls -lah'
alias la='ls -a'
alias no='ls' # for dvorak
alias vimconf='vim ~/.vimrc'
alias zshconf='vim ~/.zshrc'

# Use MacVim's build of vim if it exists on the system
command -v mvim >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "vim: using macvim build"
  alias vim='/usr/local/Cellar/macvim/7.3-64/MacVim.app/Contents/MacOS/Vim'
fi

### Ruby ###
if [ -d "$HOME/.rvm" ]; then
  PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
fi


### Confirm load ###
echo "energize!"

