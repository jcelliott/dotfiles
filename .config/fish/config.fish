# fish shell config
#
# Joshua Elliott

# put anything needed for a non-interactive shell before this
if not status --is-interactive
  exit 0
end

# set base16 colors
eval sh $HOME/.config/base16-shell/base16-default.dark.sh

os_detect

if not set -q fish_user_abbreviations
  abbr_set
end

# this only sets the variables if they aren't defined
set_fish_colors

# Editor
set -x EDITOR vim

if available vimpager
  set -x MANPAGER vimpager
end

### Program-specific settings ###

# ls
if test $_platform = "darwin"
  set -x LS_COLORS (bash -c 'eval `gdircolors ~/.config/.dircolors`; echo $LS_COLORS')
else
  set -x LS_COLORS (bash -c 'eval `dircolors ~/.config/.dircolors`; echo $LS_COLORS')
end

# grep
set -x GREP_OPTIONS "--color=auto"

# rsync
set -x RSYNC_PARTIAL_DIR .rsync-tmp

# less
set -x LESS -riW

### PATH ###

# Go
set -x GOPATH "$HOME/projects/go"
if test $_platform = "darwin"
  # macports go root directory
  set -x GOROOT "/opt/local/lib/go"
end

# Path
if not set -q -U fish_user_paths
  if test $_platform = "darwin"
    # path for macports
    set -U fish_user_paths "/opt/local/bin" "/opt/local/sbin"
    # path for local python packages (pip install --user)
    set -U fish_user_paths $fish_user_paths "$HOME/Library/Python/2.7/bin"
  end
  set -U fish_user_paths $fish_user_paths "$HOME/bin" "$GOPATH/bin" "$HOME/.local/bin" "/usr/local/bin"
end

# Manpath
if test $_platform = "darwin"
  # manpath for macports
  set -x MANPATH "/opt/local/share/man" "/usr/share/man" "/usr/local/share/man" $MANPATH
end

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
if test -f /usr/share/autojump/autojump.fish
  source /usr/share/autojump/autojump.fish
else if test -f /opt/local/etc/profile.d/autojump.fish
  source /opt/local/etc/profile.d/autojump.fish
else if test -f $HOME/.local/etc/profile.d/autojump.fish
  # installed with ./install.py -d ~/.local
  source $HOME/.local/etc/profile.d/autojump.fish
else
  perror "autojump not installed"
end
