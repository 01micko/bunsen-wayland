#!/usr/bin/env bash

# set theme
change_gtk_theme() {
    theme=$1
    theme=${theme/_/ }
    theme=${theme/_/ } # do it twice if 2 spaces
    echo "$theme"
    gsettings set org.gnome.desktop.interface gtk-theme "$theme"
    [[ -f "$HOME/.gtkrc-2.0" ]] && \
     [[ -d "/usr/share/themes/$theme/gtk-2.0" ]] && \
     sed -i "s/gtk-theme-name =.*$/gtk-theme-name = \"$theme\"/" $HOME/.gtkrc-2.0
    [[ -f "$HOME/.config/gtk-3.0/settings.ini" ]] && \
      [[ -d "/usr/share/themes/$theme/gtk-3.0" ]] && \
      sed -i "s/gtk-theme-name =.*$/gtk-theme-name = $theme/" $HOME/.config/gtk-3.0/settings.ini
    [[ -f "$HOME/.config/gtk-4.0/settings.ini" ]] && \
      [[ -d "/usr/share/themes/$theme/gtk-4.0" ]] && \
    sed -i "s/gtk-theme-name =.*$/gtk-theme-name = $theme/" $HOME/.config/gtk-4.0/settings.ini
}

# find themes
var=$(find /usr/share/themes -type d -name gtk-3.0 | sed -e 's/\/usr\/share\/themes\///' -e 's/\/gtk\-3\.0$//' -e 's/ /_/g' | while read -r i; do \
  echo -n "false $i ";done | sed 's/^false / true /')

# yad gui
OUT=$(yad --title="GTK Theme" --window-icon=preferences-desktop-theme --name=preferences-desktop-theme \
  --list --radiolist \
  --width=350 --height=300 \
  --column=Choose --column="GTK Theme" \
  $var | sed 's/TRUE//' | tr -d '|')
[[ -n "$OUT" ]] && change_gtk_theme "$OUT" || exit

