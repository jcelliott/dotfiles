function abbr_add --description 'append abbreviations to universal list'
	set -U fish_user_abbreviations $fish_user_abbreviations $argv
end
