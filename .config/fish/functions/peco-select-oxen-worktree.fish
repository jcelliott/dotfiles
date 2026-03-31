function peco-select-oxen-worktree
  set -l project_root "$HOME/src/oxen/Oxen"
  set -l worktrees_dir "$HOME/src/oxen/Oxen__worktrees"
  set -l query "$argv[1]"

  set peco_flag "--layout=bottom-up" "--initial-filter=Fuzzy" "--select-1"
  if [ -n $query ]
    set peco_flag $peco_flag "--query" $query
  end

  # List "main" plus any worktree directory names
  begin
    echo main
    ls $worktrees_dir
  end | peco $peco_flag | read worktree

  if [ $worktree ]
    oxen-switch $worktree
  else
    commandline -f repaint
  end
end

