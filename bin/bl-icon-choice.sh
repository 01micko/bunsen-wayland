#!/usr/bin/env bash

# set theme
change_icon_theme() {
    theme="$1"
    theme=${theme/_/ }
    theme=${theme/_/ } # twice if 2 spaces
    echo "$theme"
    gsettings set org.gnome.desktop.interface icon-theme "$theme"
    [[ -f "$HOME/.gtkrc-2.0" ]] && \
      sed -i "s/gtk-icon-theme-name =.*$/gtk-icon-theme-name = \"$theme\"/" $HOME/.gtkrc-2.0
    [[ -f "$HOME/.config/gtk-3.0/settings.ini" ]] && \
      sed -i "s/gtk-icon-theme-name =.*$/gtk-icon-theme-name = $theme/" $HOME/.config/gtk-3.0/settings.ini
    [[ -f "$HOME/.config/gtk-4.0/settings.ini" ]] && \
    sed -i "s/gtk-icon-theme-name =.*$/gtk-icon-theme-name = $theme/" $HOME/.config/gtk-4.0/settings.ini
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
[[ -n "$OUT" ]] && change_icon_theme "$OUT" || exit
