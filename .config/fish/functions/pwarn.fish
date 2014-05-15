function pwarn --description "print yellow text"
  # echo -e "\x1b[33m$argv\x1b[0m" # yellow
  echo (set_color yellow)$argv(set_color normal)
end

