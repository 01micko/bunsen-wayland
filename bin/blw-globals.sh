#!/usr/bin/env bash

# (c) Copyright 2024 Mick Amadio <01micko@gmail.com>
# set theme (0 for gtk, 1 for icons)
change_theme() {
    theme=("$@")
    echo ${theme[0]}
    echo ${theme[1]} ${theme[2]} ${theme[3]}
    [[ "${theme[0]}" == "$CUR_THEME" ]] && bl-theme_error 0 && exit 0

    yad --title="Confirm" --window-icon=dialog-question --name=dialog-question \
        --image=dialog-question \
        --text="Do you want to change the global theme from $CUR_THEME to ${theme[0]}?\n \
        This changes gtk-theme, icon-theme and wallpaper"
    case $? in
        0);;
        *)exit;;
    esac
    exit
    
    # gtk
    change_g ${theme[1]} 0 || bl-theme_error 1
    # if there's an openbox theme do that too
    n=$(grep -n '<theme>' $HOME/.config/labwc/rc.xml)
    n=${n%\:*}
    n=$((n + 1))
    [[ -d "/usr/share/themes/${theme[1]}/openbox-3" ]] && \
      sed -i "${n}s/<name>.*$/<name>${theme[1]}<\/name>/" $HOME/.config/labwc/rc.xml || bl-theme_error 1
      # reconfigure labwc
      labwc -r || bl-theme_error 0
    # icons
    change_g ${theme[2]} 1 || bl-theme_error 1
    # wall
    dir="$HOME/Pictures/wallpapers/bunsen/default"
    # write to config for labwc/autostart (swaybg and swaylock)
    echo "WALL=$dir/${theme[3]}" > $HOME/.config/bunsen/wall.conf
    # set if now
    swaybg -i "$dir/${theme[3]}" -m stretch &
    # finally, fix the config
    sed -i "s/true/false/" $HOME/.config/bunsen/global_themes.conf
    line_no=$(grep -n "${theme[0]}" $HOME/.config/bunsen/global_themes.conf)
    line_no=${line_no%\:*}
    sed -i "${line_no}s/false/${theme[4]}/" $HOME/.config/bunsen/global_themes.conf
}

# change gsettings
change_g() {
    case $2 in
        0)g=gtk;;
        1)g=icon;;
    esac
    gsettings set org.gnome.desktop.interface ${g}-theme "$1"
    if [[ "$g" == 'gtk' ]];then
        [[ -f "$HOME/.gtkrc-2.0" ]] && \
        [[ -d "/usr/share/themes/$1/gtk-2.0" ]] && \
          sed -i "s/gtk-theme-name=.*$/gtk-theme-name=\"$1\"/" $HOME/.gtkrc-2.0 || return 1
        [[ -f "$HOME/.config/gtk-3.0/settings.ini" ]] && \
        [[ -d "/usr/share/themes/$1/gtk-3.0" ]] && \
          sed -i "s/gtk-theme-name=.*$/gtk-theme-name=$1/" $HOME/.config/gtk-3.0/settings.ini || return 1
        [[ -f "$HOME/.config/gtk-4.0/settings.ini" ]] && \
        [[ -d "/usr/share/themes/$1/gtk-4.0" ]] && \
          sed -i "s/gtk-theme-name=.*$/gtk-theme-name=$1/" $HOME/.config/gtk-4.0/settings.ini || return 1
    else
        [[ -f "$HOME/.gtkrc-2.0" ]] && \
          sed -i "s/gtk-icon-theme-name=.*$/gtk-icon-theme-name=\"$1\"/" $HOME/.gtkrc-2.0 || return 1
        [[ -f "$HOME/.gtkrc-2.0" ]] && \
          sed -i "s/gtk-icon-theme-name=.*$/gtk-icon-theme-name=$1/" $HOME/.config/gtk-3.0/settings.ini || return 1
        [[ -f "$HOME/.gtkrc-2.0" ]] && \
          sed -i "s/gtk-icon-theme-name=.*$/gtk-icon-theme-name=$1/" $HOME/.config/gtk-4.0/settings.ini || return 1
    fi
    return 0
}

# find themes
. $HOME/.config/bunsen/global_themes.conf
[[ "${BL_AQUA[4]}" == 'true' ]] && CUR_THEME=${BL_AQUA[0]}
[[ "${BL_DKRED[4]}" == 'true' ]] && CUR_THEME=${BL_DKRED[0]}
[[ "${BL_BKR[4]}" == 'true' ]] && CUR_THEME=${BL_BKR[0]}

var="${BL_AQUA[4]} ${BL_AQUA[0]} ${BL_AQUA[1]} ${BL_AQUA[2]} ${BL_AQUA[3]} \
  ${BL_DKRED[4]} ${BL_DKRED[0]} ${BL_DKRED[1]} ${BL_DKRED[2]} ${BL_DKRED[3]} \
  ${BL_BKR[4]} ${BL_BKR[0]} ${BL_BKR[1]} ${BL_BKR[2]} ${BL_BKR[3]}"

OUT=($(yad --title="Global Theme - Currently: $CUR_THEME" --window-icon=preferences-desktop-theme --name=preferences-desktop-theme \
  --list --radiolist \
  --width=700 --height=300 \
  --column=Choose --column=Name \
  --column=GTK --column=ICONS --column=Wallpaper \
  $var | sed 's/TRUE//' | tr '|' ' '))

[[ -n "$OUT" ]] && {
    change_theme "${OUT[@]}"
} || bl-theme_error 2 
