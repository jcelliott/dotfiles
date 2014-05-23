function fish_prompt --description 'Write out the prompt'
	
	set -l last_status $status

	# Just calculate these once, to save a few cycles when displaying the prompt
	if not set -q __fish_prompt_hostname
		set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
	end

	if not set -q __fish_prompt_normal
		set -g __fish_prompt_normal (set_color normal)
	end
	
	if not set -q -g __fish_update_functions_defined
		set -g __fish_update_functions_defined

		function __fish_repaint_user --on-variable fish_color_user --description "Event handler, repaint when fish_color_user changes"
			if status --is-interactive
				set -e __fish_prompt_user
				commandline -f repaint ^/dev/null
			end
		end
		
		function __fish_repaint_host --on-variable fish_color_host --description "Event handler, repaint when fish_color_host changes"
			if status --is-interactive
				set -e __fish_prompt_host
				commandline -f repaint ^/dev/null
			end
		end
		
		function __fish_repaint_status --on-variable fish_color_status --description "Event handler; repaint when fish_color_status changes"
			if status --is-interactive
				set -e __fish_prompt_status
				commandline -f repaint ^/dev/null
			end
		end
    
    function __fish_set_virtualenv_prompt --on-variable VIRTUAL_ENV --description "Event handler; change virtualenv prompt when VIRTUAL_ENV changes"
      if status --is-interactive
        if set -q VIRTUAL_ENV
          set -g __fish_prompt_virtualenv (set_color purple)"("(basename "$VIRTUAL_ENV")")"(set_color normal)
        else
          set -g __fish_prompt_virtualenv
        end
      end
    end

    # function __fish_about_to_display_prompt --on-event fish_prompt
    #   echo "about to display prompt"
    # end
    # set -g __fish_last_status 0
	end


	set -l delim '>'

	switch $USER

	case root

		if not set -q __fish_prompt_cwd
			if set -q fish_color_cwd_root
				set -g __fish_prompt_cwd (set_color $fish_color_cwd_root)
			else
				set -g __fish_prompt_cwd (set_color $fish_color_cwd)
			end
		end

	case '*'

		if not set -q __fish_prompt_cwd
			set -g __fish_prompt_cwd (set_color $fish_color_cwd)
		end

	end

  # echo "--- $history[1]"
  # echo "--- $history[2]"
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

	set -l prompt_status
	if test $last_status -ne 0
		if not set -q __fish_prompt_status
			set -g __fish_prompt_status (set_color $fish_color_status)
		end
		set prompt_status "$__fish_prompt_status [$last_status]$__fish_prompt_normal"
	end

	if not set -q __fish_prompt_user
		set -g __fish_prompt_user (set_color $fish_color_user)
	end
	if not set -q __fish_prompt_host
		set -g __fish_prompt_host (set_color $fish_color_host)
	end

  if set -q CMD_DURATION
    echo (set_color --bold black) "> $CMD_DURATION" "$__fish_prompt_normal"
  end

	echo -n -s "$__fish_prompt_virtualenv" "$__fish_prompt_user" "$USER" "$__fish_prompt_normal" @ "$__fish_prompt_host" "$__fish_prompt_hostname" "$__fish_prompt_normal" ' ' "$__fish_prompt_cwd" (prompt_pwd) (__fish_git_prompt) "$__fish_prompt_normal" "$prompt_status" (fish_vi_prompt_mode) ' '
end
