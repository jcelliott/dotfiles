function fish_vi_prompt_mode --description 'Changes the prompt based on the vi mode'
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
  end
  set_color normal
end
