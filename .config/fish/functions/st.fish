function st -d "Get VCS and other status of current directory"
  if git rev-parse --is-inside-work-tree &>/dev/null
    git status
  else
    oxen status
  end
end

