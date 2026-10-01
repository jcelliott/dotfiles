function oxen-server-loop
	# cd ~/src/oxen/Oxen/oxen-rust

	while true
		echo -e (set_color brblack)"*\n*\n*"(set_color normal)
		if test -e Cargo.toml
			pinfo "***** BUILDING ****"
			cargo build
			echo "Built oxen on branch: "(git rev-parse --abbrev-ref HEAD)
		else
			pwarn "***** SKIPPING BUILD ****"
		end
		echo -e (set_color brblack)"*\n*\n*"(set_color normal)
		psuccess "***** SERVER START *****"
		# Samples this boot into its own CSV; finds the server as our child, so it is
		# fine that it races the server start. Must be a separate process, not
		# `oxen-server-sample &`: fish runs a backgrounded function synchronously,
		# which stalls the server start until the function returns.
		fish -c "oxen-server-sample $fish_pid" </dev/null >/dev/null 2>&1 &
		disown 2>/dev/null
		oxen-server start -i localhost
		perror "***** SERVER STOPPED *****"
		pwarn "(^c again to quit)"
		sleep 2
	end
end
