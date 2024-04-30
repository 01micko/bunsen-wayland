#!/usr/bin/env bash

# (c) Copyright 2024 Mick Amadio <01micko@gmail.com>

# set the image
set_wall() {
    echo setting $1
    WALL=''
    if [[ -f "$HOME/.config/bunsen/wall.conf" ]];then
        . $HOME/.config/bunsen/wall.conf
		OLDWALL=$WALL
	fi
	wall=${1##*/}
    oldwall=${WALL##*/}
    if [[ "$wall" == "$oldwall" ]];then
        yad --title="Icons" --window-icon=dialog-warning --name=dialog-warning \
            --image=dialog-warning --button="Ok!gtk-ok!" text="Wallpapers are the same!"
        exit
    fi
    yad --title="Confirm" --window-icon=dialog-question --name=dialog-question \
                --image=dialog-question \
                --text="Do you want to change wallpapers from $oldwall to $wall?"
    case $? in
        0);;
        *)exit;;
    esac
     # write to config for labwc/autostart (swaybg and swaylock)
    echo "WALL=$1" > $HOME/.config/bunsen/wall.conf
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
