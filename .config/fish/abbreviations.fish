# Set fish user abbreviations
abbr_add 'g=git'
abbr_add 'gst=git status'
abbr_add 'gc=git commit -v'
# abbr_add 'glg=git log --all --stat --graph --decorate'
abbr_add 'glg=git log-detail'
abbr_add 'glb=git log-branch'
abbr_add 'glgs=git log-summary'
abbr_add 'ga=git add'
abbr_add 'gsa=git submodule add' # gsa <repo> <directory>
abbr_add 'gsi=git submodule init'
abbr_add 'gsu=git submodule update'
abbr_add 'gsuu=git submodule foreach git pull origin master'
abbr_add 'gcm=git checkout master'
abbr_add 'gch=git checkout'
abbr_add 'gcb=git checkout -b'
abbr_add 'gd=git diff'
abbr_add 'gdc=git diff --cached'
abbr_add 'gds=git diff --stat'
abbr_add 'gmm=git merge master'

abbr_add 'v=vim'
abbr_add 'vv=vim ~/.vimrc'
abbr_add 'vf=vim ~/.config/fish/config.fish'

abbr_add 'd=docker'
abbr_add 'dl=docker ps -lq'
abbr_add 'dim=docker images'
abbr_add 'dps=docker ps'
abbr_add 'dpsa=docker ps -a'
abbr_add 'drma=docker rm (docker ps -aq)'
abbr_add 'drml=docker rm (docker ps -lq)'
abbr_add 'dsl=docker stop (docker ps -lq)'
abbr_add 'dsa=docker stop (docker ps -aq)'
abbr_add 'drmdi=docker rmi (docker images -qf dangling=true)'
abbr_add 'dimg=docker_images'

abbr_add 's=ssh'
abbr_add 'c=cat'
abbr_add 'e=echo'

abbr_add 'fc=source ~/.config/fish/config.fish'
abbr_add 'sf=source ~/.config/fish/config.fish'
