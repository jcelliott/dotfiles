function fuzzy-oxen-worktree
  set -l worktrees_dir "$HOME/src/oxen/Oxen__worktrees"
  set -l query "$argv[1]"

  set -l fzf_flags --select-1
  if [ -n "$query" ]
    set fzf_flags $fzf_flags --query=$query
  end

  # List "main" plus any worktree directory names
  begin
    echo main
    ls $worktrees_dir
  end | fzf $fzf_flags | read worktree

  if [ $worktree ]
    oxen-switch $worktree
  else
    commandline -f repaint
  end
end
