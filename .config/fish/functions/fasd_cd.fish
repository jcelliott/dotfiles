# from github.com/oh-my-fish/plugin-fasd
function fasd_cd -d 'Function to execute built-in cd'
  # if no $argv, identical to `fasd`
  if test (count $argv) -le 1
    command fasd "$argv"
  else
    set -l ret (command fasd -e 'printf %s' $argv)
    test -z "$ret";
      and return
    test -d "$ret";
      and cd "$ret";
      or printf "%s\n" $ret
  end
end
