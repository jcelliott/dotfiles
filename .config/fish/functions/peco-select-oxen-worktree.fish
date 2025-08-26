function peco-select-oxen-worktree
  set -l project_root "$HOME/src/oxen/Oxen"

  set -l query "$argv[1]"


  set peco_flag "--layout=bottom-up" "--initial-filter=Fuzzy" "--select-1"
  if [ -n $query ]
	set peco_flag $peco_flag "--query" $query
  end

  if [ "$status" = "0" ]
    ls $project_root | peco $peco_flag | read worktree
  else
    return 1
  end

  if [ $worktree ]
    oxen-switch $worktree
  else
    commandline -f repaint
  end
end

