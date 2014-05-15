function psuccess --description "print green text"
  # echo -e "\x1b[32m$argv\x1b[0m" # green
  echo (set_color green)$argv(set_color normal)
end

