# fish shell config
#
# Joshua Elliott

# put anything needed for a non-interactive shell before this
if not status --is-interactive
  exit 0
end

# set base16 colors
set BASE16_SHELL "$HOME/.config/base16-shell"
source "$BASE16_SHELL/profile_helper.fish"
base16-default-dark

os_detect

# Emulates vim's cursor shape behavior
# Set the normal and visual mode cursors to a block
set -x fish_cursor_default block
# Set the insert mode cursor to a line
set -x fish_cursor_insert line
# Set the replace mode cursor to an underscore
set -x fish_cursor_replace_one underscore
# set -x fish_vi_force_cursor true

if not set -q fish_abbreviations_set
  abbr_set
end

# this only sets the variables if they aren't defined
set_fish_colors

# Editor
set -x EDITOR vim

### Program-specific settings ###

# ls
if test $_platform = "darwin"
  set -x LS_COLORS (bash -c 'eval `gdircolors ~/.config/.dircolors`; echo $LS_COLORS')
else
  set -x LS_COLORS (bash -c 'eval `dircolors ~/.config/.dircolors`; echo $LS_COLORS')
end

# grep
set -x GREP_OPTIONS "--color=auto"
# ripgrep
set -x RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep"

# rsync
set -x RSYNC_PARTIAL_DIR .rsync-tmp

# less
set -x LESS -RiW

# ssh - use '--apple-use-keychain'
set -x APPLE_SSH_ADD_BEHAVIOR "macos"

# Java
if test $_platform = "darwin"
  set -x JAVA_HOME "/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home"
end

### PATH ###

# asdf is installed; add asdf paths before others
if test -f /usr/local/opt/asdf/asdf.fish
  source /usr/local/opt/asdf/asdf.fish
else if test -f $HOME/.asdf/asdf.fish
  source $HOME/.asdf/asdf.fish
end

# Go
set -x GOPATH "$HOME/src/go"
if test $_platform = "darwin"
  # macports go root directory
  # set -x GOROOT "/opt/local/lib/go"
  # brew go root directory
  set -x GOROOT "/usr/local/opt/go/libexec"
end

# Path
if test $_platform = "darwin"
  # path for Homebrew (add first, so other tools can override)
  fish_add_path "/usr/local/bin"
  fish_add_path "/usr/local/opt/python/libexec/bin"
  fish_add_path "/Applications/Postgres.app/Contents/Versions/latest/bin"
  fish_add_path "$HOME/.asdf/shims" "$HOME/.asdf/bin"
end

fish_add_path "$HOME/bin" "$GOPATH/bin" "$HOME/.local/bin"
fish_add_path "$HOME/.cargo/bin"  # Rust

# Manpath
if test $_platform = "darwin"
  # manpath for macports
  set -x MANPATH "/opt/local/share/man" "/usr/share/man" "/usr/local/share/man" $MANPATH
end
if test $_distro = "arch"
  set -e MANPATH
  set -x MANPATH (manpath)
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
set -g __display_git_prompt true

# disable default vi mode prompt prefix
function fish_mode_prompt
end

# Virtualfish (Python virtualenv)
set -g VIRTUALFISH_COMPAT_ALIASES
source "$HOME/.local/share/virtualfish/virtual.fish"
# Don't overwrite prompt in virtualenv (I'm already handling this in
# fish_right_prompt)
set -x VIRTUAL_ENV_DISABLE_PROMPT true

fundle plugin 'oh-my-fish/plugin-peco'
fundle plugin 'tuvistavie/fish-completion-helpers'
fundle plugin 'edc/bass'
fundle plugin 'laughedelic/pisces'
  set -U pisces_only_insert_at_eol 1
fundle plugin 'franciscolourenco/done'
fundle init

# Elixir/Erlang
set -x ERL_AFLAGS "-kernel shell_history enabled"

# fasd
if type -q fasd
  # hook fasd into fish preexec event
  function __fasd_run -e fish_preexec
    command fasd --proc (command fasd --sanitize "$argv") > "/dev/null" 2>&1
  end
else
  perror "fasd is not installed"
end

# franciscolourenco/done
set -U __done_exclude 'vim|less'

# Base16 Shell
# eval sh $HOME/.base16-default.dark.sh

# Aliases
# https://github.com/sharkdp/bat
if available bat
  alias cat=bat
end
if available exa
  alias ls=exa
  alias l='exa -l'
  alias la='exa -la'
end
if available mix
  alias dialyze='env MIX_ENV=test mix dialyzer'
end

alias dark='base16-default-dark'
alias light='base16-default-light'

test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

# Android development
set -x ANDROID_HOME "/usr/local/share/android-sdk"
set -x ANDROID_SDK_ROOT "/usr/local/share/android-sdk"

# Ruby
if test -e /usr/local/share/chruby/chruby.fish
  source /usr/local/share/chruby/chruby.fish
end
