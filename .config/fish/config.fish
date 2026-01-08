# fish shell config
#
# Joshua Elliott

# put anything needed for a non-interactive shell before this
if not status --is-interactive
  exit 0
end

### Appearance ###
#
# set base16 colors
set BASE16_SHELL "$HOME/.config/base16-shell"
source "$BASE16_SHELL/profile_helper.fish"
# don't set the theme here, so it can be switched dynamically
# base16-default-dark

# Emulates vim's cursor shape behavior
# Set the normal and visual mode cursors to a block
set -x fish_cursor_default block
# Set the insert mode cursor to a line
set -x fish_cursor_insert line
# Set the replace mode cursor to an underscore
set -x fish_cursor_replace_one underscore
# set -x fish_vi_force_cursor true

# set colors
set -U fish_color_command blue
set -U fish_color_user blue
set -U fish_color_host cyan
set -U fish_color_cwd green
set -U fish_color_status red
set -U fish_color_search_match --background=red
set -U fish_color_selection --background=green

### Environment ###
#
os_detect

set -x EDITOR vim

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
# Note: prefer global paths (fish_add_path -g) so we don't have universal
# variables sticking around with old path values

# asdf is installed; add asdf paths before others
# if test -f /usr/local/opt/asdf/asdf.fish
#   source /usr/local/opt/asdf/asdf.fish
# else if test -f $HOME/.asdf/asdf.fish
#   source $HOME/.asdf/asdf.fish
# end

# Go
set -x GOPATH "$HOME/src/go"

# Path
if test $_platform = "darwin"
  # path for Homebrew (add first, so other tools can override)
  eval (/opt/homebrew/bin/brew shellenv)
  # shellenv above isn't putting homebrew paths before system paths, the move
  # flag will move them to the correct location
  fish_add_path -gP --move "/opt/homebrew/bin" "/opt/homebrew/sbin";
  # fish_add_path "/usr/local/bin"
  fish_add_path -g "/Applications/Postgres.app/Contents/Versions/latest/bin"
end

fish_add_path -g "$HOME/bin" "$GOPATH/bin" "$HOME/.local/bin"
fish_add_path -g "$HOME/.cargo/bin"  # Rust
fish_add_path -g "/opt/homebrew/opt/rustup/bin"

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

# Python
# Virtualfish (Python virtualenv)
# Install with:
#     pipx install virtualfish
#     vf install
# Don't overwrite prompt in virtualenv (I'm already handling this in
# fish_right_prompt)
set -x VIRTUAL_ENV_DISABLE_PROMPT true
# Run my Python startup script for interactive sessions
set -x PYTHONSTARTUP "$HOME/.config/pythonstartup_manager.py"

fundle plugin 'oh-my-fish/plugin-peco'
fundle plugin 'tuvistavie/fish-completion-helpers'
fundle plugin 'edc/bass'
# fundle plugin 'laughedelic/pisces'
  # set -U pisces_only_insert_at_eol 1
fundle plugin 'franciscolourenco/done'
  set -U __done_notification_command "echo \$message | terminal-notifier -title \$title"
fundle init

# Elixir/Erlang
set -x ERL_AFLAGS "-kernel shell_history enabled"

# franciscolourenco/done
set -U __done_exclude 'vim|less'

# Base16 Shell
# eval sh $HOME/.base16-default.dark.sh

# Abbreviations
source "$HOME/.config/fish/abbreviations.fish"

# Aliases
# https://github.com/sharkdp/bat
if available bat
  alias cat=bat
end
# https://github.com/eza-community/eza
if available eza
  alias ls=eza
  alias l='eza -l'
  alias la='eza -la'
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

# Use mise for tool management
set -x MISE_PYTHON_DEFAULT_PACKAGES_FILE "$HOME/.config/mise/mise_default_python_packages"
# Activate at the end of config so mise-installed tools take priority
# if type -q mise
#   mise activate fish | source
# else
#   perror "mise is not installed"
# end

# Activate zoxide
if type -q zoxide
  zoxide init fish --cmd j | source
else
  perror "zoxide is not installed"
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

