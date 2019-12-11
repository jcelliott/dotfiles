# Set all fish abbreviations
abbr --add g 'git'
abbr --add gst 'git status'
abbr --add gs 'git status'
abbr --add gc 'git commit -v'
# abbr --add glg 'git log --all --stat --graph --decorate'
abbr --add glg 'git log-detail'
abbr --add glb 'git log-branch'
abbr --add glgs 'git log-summary'
abbr --add ga 'git add'
abbr --add gsa 'git submodule add' # gsa <repo> <directory>
abbr --add gsi 'git submodule init'
abbr --add gsu 'git submodule update'
abbr --add gss 'git submodule status'
abbr --add gsd 'git submodule deinit'
abbr --add gsuu 'git submodule foreach git pull origin master'
abbr --add gcm 'git checkout master'
abbr --add gcd 'git checkout dev'
abbr --add gch 'git checkout'
abbr --add gcb 'git checkout -b'
abbr --add gd 'git diff'
abbr --add gdc 'git diff --cached'
abbr --add gds 'git diff --stat'
abbr --add gmm 'git merge master'
abbr --add gba 'git branch -a'
abbr --add gr 'git remote -v'
abbr --add gb 'peco-select-git-branch'

abbr --add ev 'vim ~/.vimrc'
abbr --add et 'vim ~/.tmux.conf'
abbr --add efc 'vim ~/.config/fish/config.fish'
abbr --add eff 'vim ~/.config/fish/functions'
abbr --add ef 'vim ~/.config/fish'
abbr --add vs 'vim-search'
abbr --add vsa 'vim-search --no-ignore'

abbr --add vup 'vagrant up'
abbr --add vsh 'vagrant ssh'

abbr --add d 'docker'
abbr --add dl 'docker ps -lq' # display id of latest created container
abbr --add dim 'docker images'
abbr --add dpsa 'dps -a'
abbr --add drma 'docker rm (docker ps -aq)' # delete all stopped containers
abbr --add drml 'docker rm (docker ps -lq)' # delete last container
abbr --add dsa 'docker stop (docker ps -aq)' # stop all containers
abbr --add dsl 'docker stop (docker ps -lq)' # stop last container
abbr --add drmdi 'docker rmi (docker images -qf dangling=true)' # delete dangling images
abbr --add digrep 'docker-images' # grep through images
abbr --add dgrep 'docker-grep' # grep through containers
abbr --add drmg 'docker rm (docker-grep'
abbr --add dpid 'docker inspect --format \'{{.State.Pid}}\' (docker ps -lq)'
abbr --add dcl 'docker rm (docker ps -aq); docker rmi (docker images -qf dangling=true)' # clean
abbr --add de 'docker exec'

abbr --add dc 'docker-compose'
abbr --add dcu 'docker-compose up -d'
abbr --add dcs 'docker-compose stop'

abbr --add dm 'docker-machine'

abbr --add c 'code'

abbr --add fc 'source ~/.config/fish/config.fish'
abbr --add sf 'source ~/.config/fish/config.fish'

abbr --add s 'sudo'
abbr --add se 'sudo -E'
abbr --add sudoe 'sudo -E'

abbr --add rp 'rsync -rltp --partial --info=progress2'

abbr --add k 'kubectl'
abbr --add kg 'kubectl get'
abbr --add kd 'kubectl describe'
abbr --add ke 'kubectl exec'
abbr --add kc 'kubectl config'
abbr --add kcu 'kubectl config use-context'
abbr --add kcc 'kubectl config use-context'
abbr --add kcf 'kubectl create -f'
abbr --add kaf 'kubectl apply -f'
abbr --add kp 'kubectl port-forward'
abbr --add kls 'kubectl logs -f --since 1s'
abbr --add ks 'kubectl_context_switch_peco'
abbr --add ka 'kubectl_attach_pod'
abbr --add kn 'kubectl -n kube-system'

abbr --add chmox 'chmod +x'

abbr --add m 'mix'
abbr --add mdg 'mix deps.get'
abbr --add mdc 'mix deps.compile'
abbr --add mc 'mix compile'
abbr --add iexm 'iex -S mix'

abbr --add y 'yarn'

abbr --add e 'dotenv'
