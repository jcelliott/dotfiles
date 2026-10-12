# .zshenv

export LANG=en_US.UTF-8
[[ -d /opt/homebrew/bin ]] && path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
# mise shims resolve each tool's version from the cwd at exec time, so they
# must beat Homebrew's copies. .zprofile repeats this after brew shellenv.
[[ -d $HOME/.local/share/mise/shims ]] && path=($HOME/.local/share/mise/shims $path)
