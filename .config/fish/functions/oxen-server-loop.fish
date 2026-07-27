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
		oxen-server start -i localhost
		perror "***** SERVER STOPPED *****"
		pwarn "(^c again to quit)"
		sleep 2
	end
end
