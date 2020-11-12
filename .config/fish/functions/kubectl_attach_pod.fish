function kubectl_attach_pod --description 'Attach to a fuzzy-matched kubernetes pod'
  if not available kubectl
    echo "kubectl not installed"
    exit 1
  end

  set context (kubectl config current-context)
  set peco_flags "--layout=bottom-up" "--initial-filter=Fuzzy" "--prompt=[$context]> "
  if [ (count $argv) != 0 ]
    set peco_flags $peco_flags "--query=$argv"
  end

  kubectl get pods -o name | cut -d/ -f2 | peco $peco_flags | read pod

  if [ $pod ]
    kubectl exec -it $pod -- bash
  else
    echo "no pod selected"
    exit 1
  end
end

