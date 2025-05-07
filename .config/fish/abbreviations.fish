# Set all fish abbreviations
abbr --add g 'git'
abbr --add gu 'gitui'
abbr --add gst 'git status'
abbr --add gs 'git status'
abbr --add gc 'git commit -v'
# abbr --add glg 'git log --all --stat --graph --decorate'
abbr --add glg 'git log-detail'
abbr --add glb 'git log-branch'
abbr --add glgs 'git log-summary'
abbr --add ga 'git add'
abbr --add gaf 'git add -f'
abbr --add gsa 'git submodule add' # gsa <repo> <directory>
abbr --add gsi 'git submodule init'
abbr --add gsu 'git submodule update'
abbr --add gss 'git submodule status'
abbr --add gsd 'git submodule deinit'
# abbr --add gsuu 'git submodule foreach git pull origin master'
abbr --add gcm 'git checkout main'
abbr --add gcd 'git checkout development'
abbr --add gcs 'git checkout staging'
abbr --add gch 'git checkout'
abbr --add gcb 'git checkout -b'
abbr --add gd 'git diff'
abbr --add gdc 'git diff --cached'
abbr --add gds 'git diff --stat'
# abbr --add gmm 'git merge master'
abbr --add gmd 'git merge development'
abbr --add gms 'git merge staging'
abbr --add gba 'git branch -a'
abbr --add gr 'git remote -v'
abbr --add gb 'peco-select-git-branch'

abbr --add ev 'vim ~/.vimrc'
abbr --add et 'vim ~/.tmux.conf'
abbr --add efc 'vim ~/.config/fish/config.fish'
abbr --add eff 'vim ~/.config/fish/functions'
abbr --add efa 'vim ~/.config/fish/abbreviations.fish'
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

# too close to 'cd'
# abbr --add c 'code'

abbr --add sf 'source ~/.config/fish/config.fish'
abbr --add sfa 'source ~/.config/fish/abbreviations.fish'

abbr --add s 'sudo'
abbr --add se 'sudo -E'
abbr --add sudoe 'sudo -E'

abbr --add rp 'rsync -a --partial --info=progress2'

# abbr --add k 'kubectl'
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
abbr --add mcw 'mix compile --warnings-as-errors --force'
abbr --add mf 'mix format --dry-run --check-formatted'
abbr --add mm 'mix ecto.migrate'
abbr --add im 'iex -S mix'
abbr --add mp 'iex -S mix phx.server'
abbr --add mpd 'iex --dbg pry -S mix phx.server'

abbr --add y 'yarn'
abbr --add e 'dotenv'
abbr --add hm 'history --merge'
abbr --add bs 'bass source'

abbr --add o 'oxen'
abbr --add ost 'oxen status'
abbr --add oa 'oxen add'
abbr --add ob 'oxen branch'
abbr --add oc 'oxen commit -m'
abbr --add och 'oxen checkout'
abbr --add ocb 'oxen checkout -b'
abbr --add ol 'oxen log'
abbr --add op 'oxen pull'
abbr --add ostage 'oxen db list .oxen/staged'
abbr --add orefs 'oxen db list .oxen/refs'
abbr --add oprd 'oxen-prd'

abbr --add cb 'cargo build'
abbr --add ccl 'cargo clippy --no-deps -- -D warnings'
abbr --add cch 'cargo check'
abbr --add ct 'cargo test'

abbr --add ptp 'ptpython'
abbr --add py 'ptipython'
abbr --add vfa 'vf activate'
