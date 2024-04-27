#!/usr/bin/env bash

# set the image
set_wall() {
    echo setting $1
    # write to config for labwc/autostart (swaybg) and swaylock
    echo "WALL=$1" > $HOME/.config/wall.conf
    # set if now
    swaybg -i "$1" -m stretch &
}

# find the image
cd $HOME/Pictures/wallpapers/bunsen/default
OUT=$(yad --title="Wallpaper" --window-icon=preferences-desktop-wallpaper \
  --name=preferences-desktop-wallpaper --image=preferences-desktop-wallpaper \
  --image-on-top --text="<big><big>Select a wallpaper and press OK</big></big>" \
  --file)
cd -
[[ -n "$OUT" ]] && set_wall $OUT
