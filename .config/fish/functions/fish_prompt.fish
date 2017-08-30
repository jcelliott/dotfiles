function fish_prompt --description 'Write out the prompt'

	set -l last_status $status

	# Just calculate these once, to save a few cycles when displaying the prompt
	if not set -q __fish_prompt_hostname
		set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
	end
	if not set -q __fish_prompt_normal
		set -g __fish_prompt_normal (set_color normal)
	end
    if not set -q __fish_prompt_cwd
        set -g __fish_prompt_cwd (set_color $fish_color_cwd)
    end
	if not set -q __fish_prompt_user
        if set -q fish_prompt_show_user
            set -g __fish_prompt_user (set_color $fish_color_user)"$USER"(set_color normal)
        else
            set -g __fish_prompt_user ""
        end
	end
	if not set -q __fish_prompt_host
        if set -q fish_prompt_show_host
            set -g __fish_prompt_host "@"(set_color $fish_color_host)"$__fish_prompt_hostname"(set_color normal)
        else
            set -g __fish_prompt_host ""
        end
	end

	if not set -q -g __fish_update_functions_defined
		set -g __fish_update_functions_defined

		function __fish_repaint_user -v fish_color_user -d "repaint when fish_color_user changes"
			if status --is-interactive
				set -e __fish_prompt_user
				commandline -f repaint ^/dev/null
			end
		end
		function __fish_repaint_user -v fish_prompt_show_user -d "repaint when fish_prompt_show_user changes"
			if status --is-interactive
				set -e __fish_prompt_user
				commandline -f repaint ^/dev/null
			end
		end

		function __fish_repaint_host -v fish_color_host -d "repaint when fish_color_host changes"
			if status --is-interactive
				set -e __fish_prompt_host
				commandline -f repaint ^/dev/null
			end
		end
		function __fish_repaint_host -v fish_prompt_show_host -d "repaint when fish_prompt_show_host changes"
			if status --is-interactive
				set -e __fish_prompt_host
				commandline -f repaint ^/dev/null
			end
		end

		function __fish_repaint_status --on-variable fish_color_status -d "Event handler; repaint when fish_color_status changes"
			if status --is-interactive
				set -e __fish_prompt_status
				commandline -f repaint ^/dev/null
			end
		end

    # function __fish_about_to_display_prompt --on-event fish_prompt
    #   echo "about to display prompt"
    # end
    # set -g __fish_last_status 0
	end

  # echo "--- $history[1]"
  # echo "--- $history[2]"
  # echo "--- last_status $last_status"
  # echo "--- __fish_last_status $__fish_last_status"
  #
	# set -l prompt_status
  # # if test $last_status -ne $__fish_last_status -o $history[1] -ne $history[2]
  # if test $last_status -ne $__fish_last_status
  #   # doesn't work because $history is not updated with last command before
  #   # prompt is displayed. See: https://github.com/fish-shell/fish-shell/issues/984
  #   if test $last_status -ne 0
  #     if not set -q __fish_prompt_status
  #       set -g __fish_prompt_status (set_color $fish_color_status)
  #     end
  #     set prompt_status "$__fish_prompt_status [$last_status]$__fish_prompt_normal"
  #   end
  #   set -g __fish_last_status $last_status
  # end
  #
    set -g __fish_last_status $last_status

	set -l prompt_status
	if test $last_status -ne 0
		if not set -q __fish_prompt_status
			set -g __fish_prompt_status (set_color $fish_color_status)
		end
		set prompt_status "$__fish_prompt_status""[$last_status]""$__fish_prompt_normal"
	end

  if set -q CMD_DURATION
    # show duration if longer than 5s
    if test $CMD_DURATION -gt "3000"
      echo (set_color --bold black) ">" (duration-fmt "$CMD_DURATION") "$__fish_prompt_normal"
    end
  end

    # full prompt
	echo -ns "$__fish_prompt_user" "$__fish_prompt_host" ' ' "$__fish_prompt_cwd" (prompt_pwd) (__fish_git_prompt) "$__fish_prompt_normal" "$prompt_status" (fish_vi_prompt_mode) ' '
    # short prompt
	# echo -ns ' ' "$__fish_prompt_cwd" (prompt_pwd) "$__fish_prompt_normal" "$prompt_status" (fish_vi_prompt_mode) ' '
    # minimal prompt
	# echo -ns ' ' "$prompt_status" (fish_vi_prompt_mode) ' '
end
