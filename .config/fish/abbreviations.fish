# Set fish user abbreviations
abbr_add 'g=git'
abbr_add 'gst=git status'
abbr_add 'gs=git status'
abbr_add 'gc=git commit -v'
# abbr_add 'glg=git log --all --stat --graph --decorate'
abbr_add 'glg=git log-detail'
abbr_add 'glb=git log-branch'
abbr_add 'glgs=git log-summary'
abbr_add 'ga=git add'
abbr_add 'gsa=git submodule add' # gsa <repo> <directory>
abbr_add 'gsi=git submodule init'
abbr_add 'gsu=git submodule update'
abbr_add 'gss=git submodule status'
abbr_add 'gsd=git submodule deinit'
abbr_add 'gsuu=git submodule foreach git pull origin master'
abbr_add 'gcm=git checkout master'
abbr_add 'gcd=git checkout dev'
abbr_add 'gch=git checkout'
abbr_add 'gcb=git checkout -b'
abbr_add 'gd=git diff'
abbr_add 'gdc=git diff --cached'
abbr_add 'gds=git diff --stat'
abbr_add 'gmm=git merge master'
abbr_add 'gba=git branch -a'
abbr_add 'gr=git remote -v'
abbr_add 'gb=peco-select-git-branch'

abbr_add 'v=vim'
abbr_add 'ev=vim ~/.vimrc'
abbr_add 'et=vim ~/.tmux.conf'
abbr_add 'efc=vim ~/.config/fish/config.fish'
abbr_add 'eff=vim ~/.config/fish/functions'
abbr_add 'ef=vim ~/.config/fish'

abbr_add 'vup=vagrant up'
abbr_add 'vsh=vagrant ssh'

abbr_add 'd=docker'
abbr_add 'dl=docker ps -lq' # display id of latest created container
abbr_add 'dim=docker images'
abbr_add 'dpsa=dps -a'
abbr_add 'drma=docker rm (docker ps -aq)' # delete all stopped containers
abbr_add 'drml=docker rm (docker ps -lq)' # delete last container
abbr_add 'dsa=docker stop (docker ps -aq)' # stop all containers
abbr_add 'dsl=docker stop (docker ps -lq)' # stop last container
abbr_add 'drmdi=docker rmi (docker images -qf dangling=true)' # delete dangling images
abbr_add 'digrep=docker-images' # grep through images
abbr_add 'dgrep=docker-grep' # grep through containers
abbr_add 'drmg=docker rm (docker-grep'
abbr_add 'dpid=docker inspect --format \'{{.State.Pid}}\' (docker ps -lq)'
abbr_add 'dcl=docker rm (docker ps -aq); docker rmi (docker images -qf dangling=true)' # clean
abbr_add 'de=docker exec'

abbr_add 'dc=docker-compose'
abbr_add 'dcu=docker-compose up -d'
abbr_add 'dcs=docker-compose stop'

abbr_add 'dm=docker-machine'

abbr_add 'c=cat'

abbr_add 'fc=source ~/.config/fish/config.fish'
abbr_add 'sf=source ~/.config/fish/config.fish'

abbr_add 's=sudo'
abbr_add 'se=sudo -E'
abbr_add 'sudoe=sudo -E'

abbr_add 'rp=rsync -rltp --partial --info=progress2'

abbr_add 'k=kubectl'
abbr_add 'kg=kubectl get'
abbr_add 'kd=kubectl describe'
abbr_add 'ke=kubectl exec'
abbr_add 'kc=kubectl config'
abbr_add 'kcu=kubectl config use-context'
abbr_add 'kcc=kubectl config use-context'
abbr_add 'kcf=kubectl create -f'
abbr_add 'kaf=kubectl apply -f'
abbr_add 'kp=kubectl port-forward'
abbr_add 'kls=kubectl logs -f --since 1s'
abbr_add 'ks=kubectl_context_switch_peco'

abbr_add 'chmox=chmod +x'

abbr_add 'm=mix'
abbr_add 'mdg=mix deps.get'
abbr_add 'mdc=mix deps.compile'
abbr_add 'mc=mix compile'
abbr_add 'iexm=iex -S mix'
