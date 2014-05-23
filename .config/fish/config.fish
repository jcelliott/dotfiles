# fish shell config
#
# Joshua Elliott

# put anything needed for a non-interactive shell before this
if not status --is-interactive
  exit 0
end

os_detect

if not set -q fish_user_abbreviations
  abbr_set
end

if test $_platform = "darwin"
  set -x LS_COLORS (bash -c 'eval `gdircolors ~/.config/.dircolors`; echo $LS_COLORS')
else
  set -x LS_COLORS (bash -c 'eval `dircolors ~/.config/.dircolors`; echo $LS_COLORS')
end

# this only sets the variables if they aren't defined
set_fish_colors

# Go
set -x GOPATH "$HOME/projects/go"

# Path
if not set -q -U fish_user_paths
  set -U fish_user_paths "$HOME/bin" "/usr/local/bin" "$GOPATH/bin" "$HOME/.local/bin"
end

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

# Base16 Shell
# eval sh $HOME/.base16-default.dark.sh

# Autojump
# installed with ./install.py -d ~/.local
if test -f $HOME/.local/etc/profile.d/autojump.fish
  source $HOME/.local/etc/profile.d/autojump.fish
end

