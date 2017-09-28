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
set -x LESS -RiW

### PATH ###

# Go
set -x GOPATH "$HOME/src/go"
if test $_platform = "darwin"
  # macports go root directory
  # set -x GOROOT "/opt/local/lib/go"
  # brew go root directory
  set -x GOROOT "/usr/local/opt/go/libexec"
end

# Path
if not set -q -U fish_user_paths
  set -U fish_user_paths "$HOME/bin" "$GOPATH/bin" "$HOME/.local/bin"
  if test $_platform = "darwin"
    # path for local python packages (pip install --user)
    set -U fish_user_paths $fish_user_paths "$HOME/Library/Python/2.7/bin"
    set -U fish_user_paths $fish_user_paths "$HOME/Library/Python/3.5/bin"
    # path for macports
    # set -U fish_user_paths $fish_user_paths "/opt/local/bin" "/opt/local/sbin"
  end
  set -U fish_user_paths $fish_user_paths "/usr/local/bin"

  # Rust
  set -U fish_user_paths $fish_user_paths "$HOME/.cargo/bin"
end

# Manpath
if test $_platform = "darwin"
  # manpath for macports
  set -x MANPATH "/opt/local/share/man" "/usr/share/man" "/usr/local/share/man" $MANPATH
end
set -x MANPATH "$HOME/.local/share/man" $MANPATH

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

# disable default vi mode prompt prefix
function fish_mode_prompt
end

# Virtualfish (Python virtualenv)
set -g VIRTUALFISH_COMPAT_ALIASES
source "$HOME/.local/share/virtualfish/virtual.fish"

fundle plugin 'oh-my-fish/plugin-peco'
fundle plugin 'tuvistavie/fish-completion-helpers'
fundle plugin 'edc/bass'
fundle init

# fasd
if type -q fasd
  # hook fasd into fish preexec event
  function __fasd_run -e fish_preexec
    command fasd --proc (command fasd --sanitize "$argv") > "/dev/null" 2>&1
  end
else
  perror "fasd is not installed"
end

# Base16 Shell
# eval sh $HOME/.base16-default.dark.sh
