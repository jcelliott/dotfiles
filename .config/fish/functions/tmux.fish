function tmux
	begin; set -lx TERM screen-256color-bce; command tmux $argv; end
end
