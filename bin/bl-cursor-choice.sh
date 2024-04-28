#!/usr/bin/env bash

# (c) Copyright 2024 Mick Amadio <01micko@gmail.com>
# set theme
change_cursor_theme() {
    theme=$1
    theme=${theme/_/ }
    echo "$theme"
    curtheme=$(gsettings get org.gnome.desktop.interface cursor-theme)
    if [[ "$theme" == "$(echo $curtheme|tr -d "'")" ]];then
        yad --title="Cursors" --window-icon=dialog-warning --name=dialog-warning \
            --image=dialog-warning --button="Ok!gtk-ok!" text="Themes are the same!"
        exit
    fi
    yad --title="Confirm" --window-icon=dialog-question --name=dialog-question \
                --image=dialog-question \
                --text="Do you want to change themes from $curtheme to $theme?"
    case $? in
        0);;
        *)exit;;
    esac
     gsettings set org.gnome.desktop.interface cursor-theme "$theme"
    # set for labwc; others later, sway, hyprland etc
	if grep -q 'XCURSOR_THEME' $HOME/.config/labwc/environment;then
        sed -i "s/XCURSOR_THEME.*$/XCURSOR_THEME=$theme/" $HOME/.config/labwc/environment
    else
        echo "XCURSOR_THEME=$theme" >> $HOME/.config/labwc/environment
    fi
}

# find themes
var=$(find /usr/share/icons -type d -name cursors  | sed -e 's/\/usr\/share\/icons\///' -e 's/\/cursors//' | while read -r i; do \
  echo -n "false $i ";done | sed 's/^false /true /')

# yad gui
OUT=$(yad --title="Icon Theme" --window-icon=preferences-desktop-cursors --name=preferences-desktop-cursors \
  --list --radiolist \
  --width=350 --height=300 \
  --column=Choose --column="Cursor Theme" \
  $var | sed 's/TRUE//' | tr -d '|')
[[ -n "$OUT" ]] && change_cursor_theme "$OUT" || exit
