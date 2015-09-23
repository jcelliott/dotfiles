function docker-images --description "search docker images"
	docker images | head -1; docker images | grep --color=never $argv
end
