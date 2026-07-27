function kubectl_attach_pod --description 'Attach to a fuzzy-matched kubernetes pod'
  if not available kubectl
    echo "kubectl not installed"
    return 1
  end

  set -l context (kubectl config current-context)
  set -l fzf_flags --prompt="[$context]> "
  if [ (count $argv) != 0 ]
    set fzf_flags $fzf_flags --query="$argv"
  end

  kubectl get pods -o name | cut -d/ -f2 | fzf $fzf_flags | read pod

  if [ $pod ]
    kubectl exec -it $pod -- bash
  else
    echo "no pod selected"
    return 1
  end
end
