function fuzzy-git-branch
  set -l query (commandline)

  set -l fzf_flags --preview 'git log --oneline --color=always -20 {}'
  if [ -n "$query" ]
    set fzf_flags $fzf_flags --query=$query
  end

  git rev-parse --git-dir >/dev/null 2>&1
  if [ "$status" = "0" ]
    # Branches bound to a worktree (the current branch included) can't be
    # checked out here, so drop them from the list.
    set -l unavailable (git worktree list --porcelain | string replace -rf '^branch refs/heads/' '')
    git branch --format='%(refname:short)' | while read -l branch
      contains -- $branch $unavailable; or echo $branch
    end | fzf $fzf_flags | read line
  else
    return 1
  end

  if [ $line ]
    git checkout $line
  else
    commandline -f repaint
  end
end
