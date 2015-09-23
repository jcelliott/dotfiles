function docker-grep --description 'search docker containers, output IDs'
  # tail -n+2: start with the second line (skip the headers)
	docker ps -a | tail -n+2 | grep $argv | cut -d\  -f1
end
