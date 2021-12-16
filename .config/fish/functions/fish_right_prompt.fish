function fish_right_prompt --description 'Write out the right prompt'
    if not set -q __fish_rprompt_color
        set -g __fish_rprompt_color (set_color --bold black)
    end

    function __fish_set_virtualenv_prompt --on-variable VIRTUAL_ENV --description "Event handler; change virtualenv prompt when VIRTUAL_ENV changes"
      if status --is-interactive
        if set -q VIRTUAL_ENV
          set -g __fish_prompt_virtualenv "["(basename "$VIRTUAL_ENV")"]"
          # set -g __fish_prompt_virtualenv "["$VIRTUAL_ENV"]"
        else
          set -g __fish_prompt_virtualenv
        end
      end
    end

    function __fish_set_conda_env_prompt --on-variable CONDA_DEFAULT_ENV --description "Event handler; change conda env prompt"
      if status --is-interactive
        if set -q CONDA_DEFAULT_ENV
          set -g __fish_prompt_conda_env "["$CONDA_DEFAULT_ENV"]"
        else
          set -g __fish_prompt_conda_env
        end
      end
    end

    function __fish_set_docker_machine_prompt --on-variable DOCKER_MACHINE_NAME --description "Event handler; change docker machine prompt when DOCKER_MACHINE_NAME changes"
      if status --is-interactive
        if set -q DOCKER_MACHINE_NAME
          set -g __fish_prompt_docker_machine "[$DOCKER_MACHINE_NAME]"
        else if set -q DOCKER_HOST
          set -g __fish_prompt_docker_machine "[DOCKER]"
        else
          set -g __fish_prompt_docker_machine
        end
      end
    end

    echo -ns "$__fish_rprompt_color" "$__fish_prompt_docker_machine" "$__fish_prompt_virtualenv" "$__fish_prompt_conda_env"
end
