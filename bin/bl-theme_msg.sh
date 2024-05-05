#!/usr/bin/env bash

# (c) Copyright 2024 Mick Amadio <01micko@gmail.com>
# called from bl-{gtk,cursor,icon}-choice.sh

case $1 in
  0)ico=warning;text="Themes are the same!";;
  1)ico=error;text="Something went horribly wrong!";;
esac

yad --title="Appearance Settings" \
  --window-icon=dialog-${ico} --name=dialog-${ico} --center \
  --image=dialog-${ico} --button="Ok!gtk-ok!" --text "${ico^}: $text"
exit $1
