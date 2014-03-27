function abbr_set --description 'set universal abbreviations list'
	set -U fish_user_abbreviations ''
  source "$HOME/.config/fish/abbreviations.fish"
end
