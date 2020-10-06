function code --description 'Open VSCode and default to current directory'
    if count $argv >/dev/null
	command code $argv
    else
	command code .
    end
end

