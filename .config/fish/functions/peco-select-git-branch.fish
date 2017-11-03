function peco-select-git-branch
  set -l query (commandline)

  set peco_flag "--layout=bottom-up" "--initial-filter=Fuzzy"
  if [ -n $query ]
	set peco_flag $peco_flag "--query $query"
  end

  git rev-parse --git-dir >/dev/null 2>&1
  if [ "$status" = "0" ]
    git branch | grep -v "*" | tail -r | awk '{ print $1 }' | peco $peco_flag | read line
  else
    return 1
  end

  if [ $line ]
    git checkout $line
  else
    commandline -f repaint
  end
end
