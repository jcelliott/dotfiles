function perror --description "print red text"
  # echo -e "\x1b[31m$argv\x1b[0m" # red
  echo (set_color red)$argv(set_color normal)
end

