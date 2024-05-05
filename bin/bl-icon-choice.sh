#!/usr/bin/env bash

# (c) Copyright 2024 Mick Amadio <01micko@gmail.com>
# set theme
change_icon_theme() {
    theme="$1"
    theme=${theme/_/ }
    theme=${theme/_/ } # twice if 2 spaces
    echo "$theme"
    curtheme=$(gsettings get org.gnome.desktop.interface icon-theme)
    if [[ "$theme" == "$(echo $curtheme|tr -d "'")" ]];then
        ./bl-theme_error 0
    fi
    yad --title="Confirm" --window-icon=dialog-question --name=dialog-question \
                --image=dialog-question \
                --text="Do you want to change themes from $curtheme to $theme?"
    case $? in
        0);;
        *)exit;;
    esac
    gsettings set org.gnome.desktop.interface icon-theme "$theme"
    [[ -f "$HOME/.gtkrc-2.0" ]] && \
      sed -i "s/gtk-icon-theme-name=.*$/gtk-icon-theme-name=\"$theme\"/" $HOME/.gtkrc-2.0 || ./bl-theme_error 1
    [[ -f "$HOME/.config/gtk-3.0/settings.ini" ]] && \
      sed -i "s/gtk-icon-theme-name=.*$/gtk-icon-theme-name=$theme/" $HOME/.config/gtk-3.0/settings.ini || ./bl-theme_error 1
    [[ -f "$HOME/.config/gtk-4.0/settings.ini" ]] && \
    sed -i "s/gtk-icon-theme-name=.*$/gtk-icon-theme-name=$theme/" $HOME/.config/gtk-4.0/settings.ini || ./bl-theme_error 1
}

# find themes
var=$(find /usr/share/icons -type d -name "48*" | grep -v hicolor | sed -e 's/\/48.*$//' -e 's/\/usr\/share\/icons\///' -e 's/ /_/' | while read -r i; do \
  echo -n "false $i ";done | sed 's/^false /true /')

# yad gui
OUT=$(yad --title="Icon Theme" --window-icon=preferences-desktop-icons --name=preferences-desktop-icons \
  --list --radiolist \
  --width=350 --height=300 \
  --column=Choose --column="Icon Theme" \
  $var | sed 's/TRUE//' | tr -d '|')
[[ -n "$OUT" ]] && change_icon_theme "$OUT" || ./bl-theme_error 1
