#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

if [ -e ~/.Xmodmap ]; then
  xmodmap ~/.Xmodmap
fi

_locker="i3lock -c 111111 -d -I 10"
xss-lock -- "$_locker" &
xautolock -time 10 -corners "00+0" -cornerdelay 2 -cornerredelay 10 -locker "$_locker" &

export SSH_ASKPASS=/usr/lib/ssh/ssh-askpass
keychain id_rsa
[ -f ~/.keychain/$HOSTNAME-sh ] && . ~/.keychain/$HOSTNAME-sh 2>/dev/null

exec i3 -c ~/.config/i3/config

