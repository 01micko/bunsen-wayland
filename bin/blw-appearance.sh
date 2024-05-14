#!/usr/bin/env bash

# (c) Copyright 2024 Mick Amadio <01micko@gmail.com> GPL3

# starter script for icon, wallpaper, gtk and cursor choices.
# and global theme setting and creating
# this script is wayland dependant
[[ -n "$WAYLAND_DISPLAY" ]] || {
    bl-theme-msg 5
    exit 5
}

yad --title="Appearance Settings" \
  --window-icon=distributor-logo-bunsenlabs --name=distributor-logo-bunsenlabs \
  --image=distributor-logo-bunsenlabs --text "<big><big>Make a choice!</big></big>\n
 Here is where you can tune the appearance of your BunsenLabs desktop.
 Choose a wallpaper, an icon theme, gtk theme, cursor theme or a global theme.
 You can even create a global theme of your current desktop" \
  --form --align=left --align-buttons\
  --field=" Wallpaper!preferences-desktop-wallpaper!choose wallpaper":fbtn 'bash -c "blw-wallpaper.sh &"' \
  --field=" Icon Theme!preferences-desktop-icons!choose icons":fbtn 'bash -c "bl-icon-choice.sh &"' \
  --field=" GTK Theme!preferences-desktop-theme!choose gtk theme":fbtn 'bash -c "bl-gtk-choice.sh &"' \
  --field=" Cursor Theme!preferences-desktop-cursors!choose cursor style":fbtn 'bash -c "bl-cursor-choice.sh &"' \
  --field=" Global Theme Set!preferences-desktop-theme!choose a global theme for gtk, icons, cursor, wallpaper":fbtn 'bash -c "blw-globals.sh &"' \
  --field=" Global Theme Create!preferences-desktop-theme!create a global theme from your current desktop":fbtn 'bash -c "blw-make-global &"' \
  --button=gtk-cancel:1
