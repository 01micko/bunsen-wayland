#!/usr/bin/env bash

# (c) Copyright 2024 Mick Amadio <01micko@gmail.com> GPL3

# set theme
change_icon_theme() {
    theme="$1"
    theme=${theme/_/ }
    theme=${theme/_/ } # twice if 2 spaces
    echo "$theme"
    curtheme=$(gsettings get org.gnome.desktop.interface icon-theme)
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
    gsettings set org.gnome.desktop.interface icon-theme "$theme"
    [[ -f "$HOME/.gtkrc-2.0" ]] && \
      sed -i "s/$curtheme/$theme/" $HOME/.gtkrc-2.0 || bl-theme-msg 2
    [[ -f "$HOME/.config/gtk-3.0/settings.ini" ]] && \
      sed -i "s/$curtheme/$theme/" $HOME/.config/gtk-3.0/settings.ini || bl-theme-msg 2
    [[ -f "$HOME/.config/gtk-4.0/settings.ini" ]] && \
    sed -i "s/$curtheme/$theme/" $HOME/.config/gtk-4.0/settings.ini || bl-theme-msg 2
}

# kill parent if exists
read BPID b c <<<$(pidof yad)
[[ -n "$BPID" ]] && kill -KILL $BPID >/dev/null 2>&1
# find themes
var=$(find /usr/share/icons -type d -name "48*" | grep -v hicolor | sed -e 's/\/48.*$//' -e 's/\/usr\/share\/icons\///' -e 's/ /_/' | while read -r i; do \
  echo -n "false $i ";done | sed 's/^false /true /')

# yad gui
OUT=$(yad --title="Icon Theme" --window-icon=preferences-desktop-icons --name=preferences-desktop-icons \
  --list --radiolist \
  --width=550 --height=375 \
  --column=Choose --column="Icon Theme" \
  $var | sed 's/TRUE//' | tr -d '|')
[[ -n "$OUT" ]] && change_icon_theme "$OUT" || bl-theme-msg 3
