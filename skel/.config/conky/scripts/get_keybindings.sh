#!/bin/bash

# strip xml comments
cat ~/.config/labwc/rc.xml|sed 's/<!--/\x0<!--/g;s/-->/-->\x0/g' |\
 grep -zv '^<!--' | tr -d '\0' |\
while read entry
do
    echo $entry | grep -q '</keyboard' && break
    echo $entry | grep -qE '<keybind|<action|<command|<menu' || continue
    if echo $entry | grep -q '<menu' ; then
        men=$(echo $entry | grep -o '>.*<' |tr -d '<' |tr -d '>')
        case $men in
            *client*)menu="Client Menu";;
            *root*)menu="Root Menu";;
            *)menu="$men";;
        esac
        echo $menu
    elif echo $entry | grep -q 'keybind' ; then
        kb=$(echo $entry | grep -o '".*"')
        case $kb in
            *'C-A-'*)kbind=$(echo $kb|sed -e "s/C\-A\-/Ctrl + Alt + /" -e 's/"//g');;
            *A-Print*)kbind=$(echo $kb|sed -e "s/A\-Print/Alt + PrtScr/" -e 's/"//g');;
            *'A-'*)kbind=$(echo $kb|sed -e "s/A\-/Alt + /" -e 's/"//g');;
            *'W-'*)kbind=$(echo $kb|sed -e "s/W\-/Super + /" -e 's/"//g');;
            *'C-'*)kbind=$(echo $kb|sed -e "s/C\-/Ctrl + /" -e 's/"//g');;
            *Print*)kbind=$(echo $kb|sed -e "s/Print/PrtScr/" -e 's/"//g');;
            *AudioLowerVolume*)kbind=$(echo $kb|sed -e "s/$kb/LowerVolume/" -e 's/"//g');;
            *AudioRaiseVolume*)kbind=$(echo $kb|sed -e "s/$kb/RaiseVolume/" -e 's/"//g');;
            *AudioMute*)kbind=$(echo $kb|sed -e "s/$kb/MuteVolume/" -e 's/"//g');;
            *MonBrightnessUp*)kbind=$(echo $kb|sed -e "s/$kb/BrightnessUp/" -e 's/"//g');;
            *MonBrightnessDown*)kbind=$(echo $kb|sed -e "s/$kb/BrightnessDown/" -e 's/"//g');;
        esac
        echo -n "$kbind\${alignr}"
    elif echo $entry | grep -q '<action' ; then
		act=$(echo $entry | grep -o '".*"')
        #echo -n " ---- $act ---- "
        case $act in 
            *ShowMenu*client*)action="Client Menu";;
            *ShowMenu*root*)action="Root Menu";;
            *ShowMenu*)action='';;
            *Close*)action="Close Window";;
            *ToggleMaximize*)action="Toggle Maximize";;
            *MoveToEdge*left*)action="Move to left";;
            *MoveToEdge*right*)action="Move to right";;
            *MoveToEdge*up*)action="Move to top";;
            *MoveToEdge*down*)action="Move to bottom";;
            *SnapToEdge*left*)action="Snap to left";;
            *SnapToEdge*right*)action="Snap to right";;
            *SnapToEdge*up*)action="Snap to top";;
            *SnapToEdge*down*)action="Snap to bottom";;
            *GoToDesktop*left*)action="Go to Desktop - left";;
            *GoToDesktop*right*)action="Go to Desktop - right";;
            *SendToDesktop*left*)action="Send to Desktop left";;
            *SendToDesktop*right*)action="Send to Desktop right";;
            *NextWindow*)action="Next Window";;
            *SnapToRegion*\"top-left\")action="Snap to top left";;
            *SnapToRegion*\"top\")action="Snap to top";;
            *SnapToRegion*\"top-right\")action="Snap to top right";;
            *SnapToRegion*\"left\")action="Snap to left";;
            *SnapToRegion*\"center\")action="Snap to center";;
            *SnapToRegion*\"right\")action="Snap to right";;
            *SnapToRegion*\"bottom-left\")action="Snap to bottom left";;
            *SnapToRegion*\"bottom\")action="Snap to bottom";;
            *SnapToRegion*\"bottom-right\")action="Snap to bottom right";;
            *term*|*tty*)action="Terminal";; # covers many terminals
            *exit*|*logout*)action="Log out";;
            *ofi*|*run*)action="Run";; # covers tofi, wofi, rofi, yofi
            *grim*)action="Screenshot";;
            *lock*)action="Lock Screen";;
            *Exe*)echo $act | grep -q 'command' && action=$(echo $act | grep -o 'command=.*"') || continue
                 action=${action#*=}
                 action=${action/\"/}
                 action=${action/\"/};;
        esac
        [ -n "$action" ] && echo "$action"
    elif echo $entry | grep -q '<command' ; then
        com=$(echo $entry | grep -o '>.*<' |tr -d '<' |tr -d '>')
        case $com in
            *ofi*|*run*)comm="Run";; # covers tofi, wofi, rofi, yofi
            *lock*)comm="Lock Screen";;
            *slurp*)comm="Screenshot(area)";;
            *grim*)comm="Screenshot";;
            *lxtask*|*term*top*|*process*)comm="Processes";; # covers many terminals top|htop
            *term*|*tty*)comm="Terminal";; # covers many terminals
            *exit*|*logout*)comm="Log out";;
        esac
        echo $comm
    fi
done       
