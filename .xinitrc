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
xautolock -time 8 -corners "00+0" -cornerdelay 3 -cornerredelay 10 -locker "$_locker" &

exec i3

