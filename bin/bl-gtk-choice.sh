#!/usr/bin/env bash

# (c) Copyright 2024 Mick Amadio <01micko@gmail.com> GPL3

# set theme
change_gtk_theme() {
    theme=$1
    theme=${theme/_/ }
    theme=${theme/_/ } # do it twice if 2 spaces
    echo "$theme"
    curtheme=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")
    if [[ "$theme" == "$curtheme" ]];then
        bl-theme_msg 0
    fi
    yad --title="Confirm" --window-icon=dialog-question --name=dialog-question \
                --image=dialog-question \
                --text="Do you want to change themes from $curtheme to $theme?"
    case $? in
        0);;
        *)exit;;
    esac
    gsettings set org.gnome.desktop.interface gtk-theme "$theme"
    [[ -f "$HOME/.gtkrc-2.0" ]] && \
     [[ -d "/usr/share/themes/$theme/gtk-2.0" ]] && \
     sed -i "s/$curtheme/$theme/" $HOME/.gtkrc-2.0 || bl-theme-msg 2
    [[ -f "$HOME/.config/gtk-3.0/settings.ini" ]] && \
      [[ -d "/usr/share/themes/$theme/gtk-3.0" ]] && \
      sed -i "s/$curtheme/$theme/" $HOME/.config/gtk-3.0/settings.ini || bl-theme-msg 2
    [[ -f "$HOME/.config/gtk-4.0/settings.ini" ]] && \
      [[ -d "/usr/share/themes/$theme/gtk-4.0" ]] && \
      sed -i "s/$curtheme/$theme/" $HOME/.config/gtk-4.0/settings.ini || bl-theme-msg 2
    # if there's an openbox theme do that too for labwc
    if [[ -r $HOME/.config/labwc/rc.xml ]];then
        n=$(grep -n '<theme>' $HOME/.config/labwc/rc.xml)
        n=${n%\:*}
        n=$((n + 1))
        [[ -d "/usr/share/themes/$theme/openbox-3" ]] && \
          sed -i "${n}s/<name>.*$/<name>$theme<\/name>/" $HOME/.config/labwc/rc.xml || bl-theme-msg 2
        # reconfigure labwc
        labwc -r || bl-theme_error 0
    fi
}

# kill parent if exists
read BPID b c <<<$(pidof yad)
[[ -n "$BPID" ]] && kill -KILL $BPID >/dev/null 2>&1
# find themes
var=$(find /usr/share/themes -type d -name gtk-3.0 | sed -e 's/\/usr\/share\/themes\///' -e 's/\/gtk\-3\.0$//' -e 's/ /_/g' | while read -r i; do \
  echo -n "false $i ";done | sed 's/^false / true /')

# yad gui
OUT=$(yad --title="GTK Theme" --window-icon=preferences-desktop-theme --name=preferences-desktop-theme \
  --list --radiolist \
  --width=550 --height=375 \
  --column=Choose --column="GTK Theme" \
  $var | sed 's/TRUE//' | tr -d '|')
[[ -n "$OUT" ]] && change_gtk_theme "$OUT" || bl-theme-msg 3

