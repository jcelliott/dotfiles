function set_fish_colors -d 'set fish user colors if not set or if --force is specified'
  if begin; not set -q -U _fish_colors_defined; or test "$argv[1]" = --force; end
    set -U _fish_colors_defined true
    psuccess "Setting fish user colors"

    set -U fish_color_command blue
    set -U fish_color_user blue
    set -U fish_color_host cyan
    set -U fish_color_cwd green
    set -U fish_color_status red
    set -U fish_color_search_match --background=red
    set -U fish_color_selection --background=green
  end
end
