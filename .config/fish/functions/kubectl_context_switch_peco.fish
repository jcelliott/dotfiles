function kubectl_context_switch_peco

  set peco_flags "--layout=bottom-up" "--initial-filter=Fuzzy"
  if [ (count $argv) != 0 ]
	set peco_flags $peco_flags "--query=$argv"
  end

  kubectl config get-contexts -o name | sort | peco $peco_flags | read ctx

  if [ $ctx ]
	kubectl config use-context $ctx
  else
	echo "context not changed"
  end

end

