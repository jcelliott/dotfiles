# fish shell config
#
# Joshua Elliott

# fish abbreviations
function add_abbr
  set -U fish_user_abbreviations $fish_user_abbreviations $argv
end

# first clear all abbreviations
set -U fish_user_abbreviations ''
add_abbr 'g=git'
add_abbr 'gst=git status'
add_abbr 'gc=git commit -v'
add_abbr 'glg=git log --all --stat --graph --decorate'
add_abbr 'ga=git add'
add_abbr 'gsa=git submodule add' # gsa <repo> <directory>
add_abbr 'gsi=git submodule init'
add_abbr 'gsu=git submodule update'
add_abbr 'gsuu=git submodule foreach git pull origin master'
add_abbr 'gcm=git checkout master'
add_abbr 'gch=git checkout'
add_abbr 'gcb=git checkout -b'
add_abbr 'gd=git diff'
add_abbr 'gdc=git diff --cached'
add_abbr 'gds=git diff --stat'

add_abbr 'v=vim'
add_abbr 'vv=vim ~/.vimrc'
add_abbr 'vf=vim ~/.config/fish/config.fish'

add_abbr 's=ssh'
add_abbr 'c=cat'
add_abbr 'e=echo'

set -x LS_COLORS (bash -c 'eval `dircolors ~/.config/.dircolors`; echo $LS_COLORS')

set -U fish_color_user blue
set -U fish_color_host cyan

# Path
set -U fish_user_paths "$HOME/bin" "/usr/local/bin"

# Editor
set -x EDITOR vim

# Fish Git prompt
set __fish_git_prompt_color yellow
# set __fish_git_prompt_stateseparator ""
# have to hack it because it defaults to space if it's empty
set ___fish_git_prompt_char_stateseparator ""
set __fish_git_prompt_showdirtystate true
set __fish_git_prompt_color_dirtystate red
set __fish_git_prompt_color_stagedstate green
set __fish_git_prompt_showstashstate true
set __fish_git_prompt_color_flags purple
set __fish_git_prompt_showuntrackedfiles true

# Virtualfish (Python virtualenv)
set -g VIRTUALFISH_COMPAT_ALIASES
source "$HOME/.local/share/virtualfish/virtual.fish"
