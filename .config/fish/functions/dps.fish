function dps --description 'more readable docker ps'
	docker ps --format 'table {{.ID}}\t{{.Image}}\t{{.Names}}\t{{.Status}}' $argv
end
