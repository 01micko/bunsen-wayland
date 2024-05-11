#!/usr/bin/env bash

# script to add 'labwc' in the window managers routine for 'neofetch'
# depends bash printf, sed, neofetch
# this puts a script named 'neofetch2' into $HOME/bin
# originally written for Bunsenlabs linux

# (c) Copyright: 2024 Mick Amadio <01micko@gmail.com>

type neofetch >/dev/null 2>&1 || {
    echo "error: neofetch is not installed"
    exit 1
}

# we need spaces before the '-e labwc' entry
entpre='-e labwc \\'

# we need the line number of 'kwin' - 'labwc' is next alphabetically
n=$(grep -n '\-e kwin' /usr/bin/neofetch)
nchars=${#n}
n=${n%\:*}
nn=${#n}
nmin=$((nn - 1)) # add the ':' plus labwc has 1 extra char
nchars=$((nchars - nmin))
# printf sets the var with -v option
printf -v ent "%${nchars}s" "$entpre"

# sed "i" inserts a line at line number
sed "${n}i \\${ent}" < /usr/bin/neofetch > $HOME/bin/neofetch2

# fix permission
chmod 755 $HOME/bin/neofetch2
