function select-oxen-repo --description "Select and output a local Oxen repo name"
  list-oxen-repos | fzf
end
