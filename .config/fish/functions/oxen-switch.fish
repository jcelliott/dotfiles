function oxen-switch
	if test (count $argv) -eq 0
		echo "Current OXEN_WORKTREE: $OXEN_WORKTREE"
		echo "Usage: oxen-switch <worktree-name>"
		echo "       oxen-switch main  # for main worktree"
		echo "       oxen-switch clear # to unset"
		return 1
	end

	if test "$argv[1]" = "clear"
		set -e OXEN_WORKTREE
		echo "Cleared OXEN_WORKTREE - will auto-detect from current directory"
	else
		set -gx OXEN_WORKTREE $argv[1]
		echo "Set OXEN_WORKTREE to $argv[1]"
	end
end
