#!/usr/bin/env bash

# (c) Copyright 2024 Mick Amadio <01micko@gmail.com>
# set theme
change_cursor_theme() {
    theme=$1
    theme=${theme/_/ }
    theme=${theme/_/ }
    echo "$theme"
    curtheme=$(gsettings get org.gnome.desktop.interface cursor-theme)
    if [[ "$theme" == "$(echo $curtheme|tr -d "'")" ]];then
        bl-theme_error 0
    fi
    yad --title="Confirm" --window-icon=dialog-question --name=dialog-question \
                --image=dialog-question \
                --text="Do you want to change themes from $curtheme to $theme?"
    case $? in
        0);;
        *)exit;;
    esac
     gsettings set org.gnome.desktop.interface cursor-theme "$theme"
    [[ -f "$HOME/.gtkrc-2.0" ]] && \
     sed -i "s/gtk-cursor-theme-name=.*$/gtk-cursor-theme-name=\"$theme\"/" $HOME/.gtkrc-2.0 || bl-theme_error 1
    [[ -f "$HOME/.config/gtk-3.0/settings.ini" ]] && \
      sed -i "s/gtk-cursor-theme-name=.*$/gtk-cursor-theme-name=$theme/" $HOME/.config/gtk-3.0/settings.ini || bl-theme_error 1
    [[ -f "$HOME/.config/gtk-4.0/settings.ini" ]] && \
    sed -i "s/gtk-cursor-theme-name=.*$/gtk-cursor-theme-name=$theme/" $HOME/.config/gtk-4.0/settings.ini || bl-theme_error 1
    # set for labwc; others later, sway, hyprland etc
	if grep -q 'XCURSOR_THEME' $HOME/.config/labwc/environment;then
        sed -i "s/XCURSOR_THEME.*$/XCURSOR_THEME=$theme/" $HOME/.config/labwc/environment || bl-theme_error 1
    else
        echo "XCURSOR_THEME=$theme" >> $HOME/.config/labwc/environment || bl-theme_error 1
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
[[ -n "$OUT" ]] && change_cursor_theme "$OUT" || bl-theme_error 1
