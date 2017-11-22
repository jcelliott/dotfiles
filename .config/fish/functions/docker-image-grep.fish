function docker-image-grep --description "search docker images, output IDs"
  # tail -n+2: start with the second line (skip the headers)
  docker images | tail -n+2 | grep $argv | awk '{print $3}'

end

