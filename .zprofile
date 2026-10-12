# .zprofile

[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
# brew shellenv re-prepends Homebrew; put the mise shims back in front (see .zshenv).
[[ -d $HOME/.local/share/mise/shims ]] && path=($HOME/.local/share/mise/shims $path)
