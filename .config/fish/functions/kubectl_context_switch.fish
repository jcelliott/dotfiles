function kubectl_context_switch
  if not available kubectl
    echo "kubectl not installed"
    return 1
  end

  set -l fzf_flags
  if [ (count $argv) != 0 ]
    set fzf_flags --query="$argv"
  end

  kubectl config get-contexts -o name | sort | fzf $fzf_flags | read ctx

  if [ $ctx ]
    kubectl config use-context $ctx
  else
    echo "context not changed"
  end
end
