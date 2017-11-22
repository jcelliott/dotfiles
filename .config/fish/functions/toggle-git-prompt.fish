function toggle-git-prompt --description "toggle git information in the prompt"
	if not set -q __display_git_prompt
		set -g __display_git_prompt "true"
	else
		set -eg __display_git_prompt
	end
	commandline -f repaint ^/dev/null
end

