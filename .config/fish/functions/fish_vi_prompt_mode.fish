function fish_vi_prompt_mode --description 'Changes the prompt based on the vi mode'
  # echo "fish_bind_mode: $fish_bind_mode "
  switch $fish_bind_mode
    case default
      set_color normal
      echo -n "^"
    case insert
      set_color red
      echo -n ">"
    case visual
      set_color magenta
      echo -n "v"
    case replace_one
      set_color red
      echo -n "r"
    case prompt-edit
      set_color --bold black
      echo -n "(P)"
    case "*"
      set_color --bold black
      echo -n "unknown-bind-mode>"
  end
  set_color normal
end
