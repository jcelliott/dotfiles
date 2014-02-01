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

add_abbr 'v=vim'
add_abbr 'vv=vim ~/.vimrc'
add_abbr 'vf=vim ~/.config/fish/config.fish'

add_abbr 's=ssh'
add_abbr 'c=cat'
add_abbr 'e=echo'

