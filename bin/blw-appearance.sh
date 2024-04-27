#!/usr/bin/env bash

# starter script for icon, wallpaper, gtk and cursor choices.

yad --title="Appearance Settings" \
  --window-icon=distributor-logo-bunsenlabs --name=distributor-logo-bunsenlabs \
  --image=distributor-logo-bunsenlabs --text "<big><big>Make a choice!</big></big>\n
  Here is where you can tune the appearance of your BunsenLabs desktop.\n
  Choose a wallpaper, an icon theme, a gtk theme or a cursor theme.\n" \
  --buttons-layout=center \
  --button=" Wallpaper!preferences-desktop-wallpaper!choose wallpaper":'bash -c "./blw-wallpaper.sh &"' \
  --button=" Icon Theme!preferences-desktop-icons!choose icons":'bash -c "./bl-icon-choice.sh &"' \
  --button=" GTK Theme!preferences-desktop-theme!choose gtk theme":'bash -c "./bl-gtk-choice.sh &"' \
  --button=" Cursor Theme!preferences-desktop-cursors!choose cursor style":'bash -c "./bl-cursor-choice.sh &"'
 
