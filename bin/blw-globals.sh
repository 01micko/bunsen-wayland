#!/usr/bin/env bash

# (c) Copyright 2024 Mick Amadio <01micko@gmail.com> GPL3

confirm_dialog() {
    yad --title="Confirm" --window-icon=dialog-question --name=dialog-question \
        --image=dialog-question \
        --text="Do you want to change the global theme from $1 to $2?\n \
        This changes gtk-theme, icon-theme, cursor-theme and wallpaper"
    return $?
}

# set theme
change_theme() {
    theme=("$@")
    echo ${theme[0]}
    echo ${CUR_THEME[0]}
    [[ "${theme[0]}" == "$CUR_THEME" ]] && return 1 # themes the same

    confirm_dialog "$CUR_THEME" "${theme[0]}"
    [[ "$?" != '0' ]] && return 3 # cancelled by $USER

    # gtk
    change_g ${theme[1]} 0 ${CUR_THEME[1]}
    # if there's an openbox theme do that too
    n=$(grep -n '<theme>' $HOME/.config/labwc/rc.xml)
    n=${n%\:*}
    n=$((n + 1))
    [[ -d "/usr/share/themes/${theme[1]}/openbox-3" ]] && \
      sed -i "${n}s/<name>.*$/<name>${theme[1]}<\/name>/" $HOME/.config/labwc/rc.xml || return 2 # error
    # reconfigure labwc
    labwc -r || bl-theme_error 0
    # icons
    change_g ${theme[2]} 1 ${CUR_THEME[2]}
    # cursor
    change_g ${theme[3]} 2 ${CUR_THEME[3]}
    # wall
    dir="$HOME/Pictures/wallpapers/bunsen/default"
    # write to config for labwc/autostart (swaybg and swaylock)
    echo "WALL=$dir/${theme[4]}" > $HOME/.config/bunsen/wall.conf
    # set it now
    swaybg -i "$dir/${theme[4]}" -m stretch &
    # finally, fix the config
    sed -i "s/true/false/g" $HOME/.config/bunsen/global_themes.conf
    line_no=$(grep -n "${theme[0]}" $HOME/.config/bunsen/global_themes.conf)
    line_no=${line_no%\:*}
    sed -i "${line_no}s/false/true/" $HOME/.config/bunsen/global_themes.conf
    # restart sfwbar if running
    sf=$(pidof sfwbar)
    [[ -n "$sf" ]] && kill -HUP $sf
}

# change gsettings
change_g() {
    case $2 in
        0)gsettings set org.gnome.desktop.interface gtk-theme "$1"
        if [[ -f "$HOME/.gtkrc-2.0" && -d "/usr/share/themes/$1/gtk-2.0" ]];then
            sed -i "s/$3/$1/" $HOME/.gtkrc-2.0 || return 2
        fi
        if [[ -f "$HOME/.config/gtk-3.0/settings.ini" && -d "/usr/share/themes/$1/gtk-3.0" ]];then
            sed -i "s/$3/$1/" $HOME/.config/gtk-3.0/settings.ini || return 2
        fi
        if [[ -f "$HOME/.config/gtk-5.0/settings.ini" && -d "/usr/share/themes/$1/gtk-3.0" ]];then
            sed -i "s/$3/$1/" $HOME/.config/gtk-4.0/settings.ini || return 2
        fi
        ;;
        1)gsettings set org.gnome.desktop.interface icon-theme "$1"
        [[ -f "$HOME/.gtkrc-2.0" ]] && \
          sed -i "s/$3/$1/" $HOME/.gtkrc-2.0 || return 2
        [[ -f "$HOME/.config/gtk-3.0/settings.ini" ]] && \
          sed -i "s/$3/$1/" $HOME/.config/gtk-3.0/settings.ini || return 2
        [[ -f "$HOME/.config/gtk-4.0/settings.ini" ]] && \
          sed -i "s/$3/$1/" $HOME/.config/gtk-4.0/settings.ini || return 2
        ;;
        2)gsettings set org.gnome.desktop.interface cursor-theme "$1"
         [[ -f "$HOME/.gtkrc-2.0" ]] && \
          sed -i "s/$3/$1/" $HOME/.gtkrc-2.0 || return 2
        [[ -f "$HOME/.config/gtk-3.0/settings.ini" ]] && \
          sed -i "s/$3/$1/" $HOME/.config/gtk-3.0/settings.ini || return 2
        [[ -f "$HOME/.config/gtk-4.0/settings.ini" ]] && \
          sed -i "s/$3/$1/" $HOME/.config/gtk-4.0/settings.ini || return 2
        # set for labwc; others later, sway, hyprland etc
        if grep -q 'XCURSOR_THEME' $HOME/.config/labwc/environment;then
            sed -i "s/XCURSOR_THEME.*$/XCURSOR_THEME=$theme/" $HOME/.config/labwc/environment || return 2
        else
            echo "XCURSOR_THEME=$theme" >> $HOME/.config/labwc/environment || return 2
        fi        
        ;;
   esac
   return 0 # success
}

usage() {
    printf "%s\n" "${0##*\/}"
    printf "\t%s\n" "This program can set a global theme."
    printf "\t%s\n" "It changes gtk theme, icon theme, cursor theme and wallpaper."
    printf "\t%s\n" "You can add to or take out options in the config file located at:"
    printf "\t%s\n" "$HOME/.config/bunsen/global_themes.conf"
    printf "\t%s\n" "For more see the man page. Type: \"man blw-appearance\" at the prompt."
    exit 0
}

case $1 in
    -h|--help)usage;;
esac

# this script is wayland dependant
[[ -n "$WAYLAND_DISPLAY" ]] || {
    bl-theme-msg 5
    exit 5
}

# kill parent if exists
read BPID b c <<<$(pidof yad)
[[ -n "$BPID" ]] && kill -KILL $BPID >/dev/null 2>&1

TDIR=$(mktemp -d /tmp/globalsXXXX)
trap "rm -rf $TDIR" EXIT

# find themes
. $HOME/.config/bunsen/global_themes.conf
while read -r a b c d e f
do 
  [[ "$a" == '#' ]] && continue
  printf "  %s \"%s%s%s%s\" %s %s %s %s %s%s%s%s%s\n" '[[' "\${" \
    "${a%\=*}" '[5]' '}' '==' "'true'" ']]' \
    '&&' 'CUR_THEME=' '(${' "${a%\=*}[@]})" >> $TDIR/themes.conf
done < $HOME/.config/bunsen/global_themes.conf
printf "%s%s\n" "CUR_THEME=" '${CUR_THEME[0]}'>> $TDIR/themes.conf
printf "%s" 'var="'>> $TDIR/themes.conf
while read -r a b c d e f
do 
  [[ "$a" == '#' ]] && continue
  printf "%s%s%s%s %s%s%s%s %s%s%s%s %s%s%s%s %s%s%s%s %s%s%s%s\n" \
'${' "${a%\=*}" '[5]' '}' '${' "${a%\=*}" '[0]' '}' \
'${' "${a%\=*}" '[1]' '}' '${' "${a%\=*}" '[2]' '}' \
'${' "${a%\=*}" '[3]' '}' '${' "${a%\=*}" '[4]' '}' >> $TDIR/themes.conf
done < $HOME/.config/bunsen/global_themes.conf
printf "%s\n" '"'>> $TDIR/themes.conf
. $TDIR/themes.conf

# main gui
OUT=($(yad --title="Global Theme - Currently: ${CUR_THEME[0]}" --window-icon=preferences-desktop-theme --name=preferences-desktop-theme \
  --list --radiolist \
  --width=700 --height=300 \
  --column=Choose --column=Name \
  --column=GTK --column=ICONS --column=CURSOR --column=Wallpaper \
  $var | sed 's/TRUE//' | tr '|' ' '))
if [[ -n "$OUT" ]];then
    change_theme "${OUT[@]}"
    ret=$?
    bl-theme-msg $ret 
else
    bl-theme-msg 3
    exit 3 
fi
    
    
