function git-not-tracked --description "list untracked, ignored files"
  # list files that are not tracked, even if ignored
  # this is useful for listing things that aren't tracked in my dotfiles,
  # for which my home directory is a git repository

  set dir (dirname $argv[1])"/"(basename $argv[1])
  comm -13 (git ls-files $dir | psub) (find $dir | cat | psub)
end
