#!/usr/bin/env bash

# wrapper script for swaylock
# (c) Copyright 2024 Mick Amadio <01micko@gmail.com>

yad_err() {
	yad --window-icon=dialog-error --name=dialog-error --image=dialog-error \
	  --title Error --text "$1"
	exit 1
}

on_graphical_session(){
    if [[ -n $DISPLAY || -n $WAYLAND_DISPLAY ]];then
        case $WAYLAND_DISPLAY in
            wayland*)return 0 ;;
            *)yad_err "Swaylock does not work in X";; # $XDG_CURRENT_DESKTOP won't be set in TUI
        esac
    fi
    exit 1
}

type swaylock >/dev/null 2>&1 || {
	yad_err "error: swaylock is not installed"
	exit 
}

IMG=/usr/share/images/bunsen/wallpapers/default/default
if [ -f "$HOME/.config/bunsen/wall.conf" ];then
    . $HOME/.config/bunsen/wall.conf
    IMG=$WALL
fi

on_graphical_session && swaylock -F -f -i $IMG
