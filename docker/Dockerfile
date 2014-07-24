# dev environment

FROM base/archlinux
MAINTAINER jcelliott

RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm --needed base-devel wget rsync abs git vim tmux
RUN mkdir -p /root/build && cd /root/build && wget https://aur.archlinux.org/packages/au/aura-bin/aura-bin.tar.gz && tar -zxf aura-bin.tar.gz && cd aura-bin && makepkg --asroot && pacman -U --noconfirm aura-bin*pkg*
RUN sudo aura -A --noconfirm fish-shell-git jq

