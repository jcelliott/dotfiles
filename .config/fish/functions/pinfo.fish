function pinfo --description "print blue text"
  # echo -e "\x1b[34m$argv\x1b[0m" # blue
  echo (set_color blue)$argv(set_color normal)
end
