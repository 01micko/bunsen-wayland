#!/usr/bin/env bash

# pass output name; eg edp1, HDMI-A-1

if [[ -n "$1" ]];then
    MON=$(wlopm | while read -r mon gone
    do
        [[ "$mon" == "$1" ]] && echo $mon && break
    done)
    monstats=($(wlr-randr | while read -r out
    do
        [[ "$MON" == "$out" ]] && echo $MON
        echo $out | grep -q 'Position' && {
            posstat=${out#* }
            posstat=${posstat%\,*}
            [[ "$posstat" == '0' ]] && continue
            echo $posstat
        }
            
        echo $out | grep -q 'current' && {
            [[ "$posstat" == '0' ]] && continue
            read dims discard <<<${out}
            echo ${dims%x*} ${dims#*x}
        }
    done))
    [[ -z "$MON" ]] && echo error && exit 1
    x=${monstats[0]}
    y=${monstats[1]}
    f=${monstats[2]}
else
    read dims discard <<<$(wlr-randr | grep current)
    x=${dims%x*}
    y=${dims#*x}
fi

appdlg=(400 100)
appprf=(550 375)
halfx=$((x / 2))
halfy=$((y / 2))
hfappgw=$((appdlg[0] / 2))
hfappgh=$((appdlg[1] / 2))
hfapppw=$((appprf[0] / 2))
hfappph=$((appprf[1] / 2))

dlgxpos=$((halfx - hfappgw))
dlgypos=$((halfy - hfappgh))
prfxpos=$((halfx - hfapppw))
prfypos=$((halfy - hfappph))

[[ -n "$1" ]] && {
    dlgxpos=$((dlgxpos + f))
    prfxpos=$((prfxpos + f))
}

ndlg=$(grep -n 'dialog-*' $HOME/.config/labwc/rc.xml)
nd=${ndlg%\:*}
ndpos=$((nd + 1))
ndsiz=$((nd + 2))
nprf=$(grep -n 'preferences-*' $HOME/.config/labwc/rc.xml)
np=${nprf%\:*}
nppos=$((np + 1))
npsiz=$((np + 2))
sed -i -e "${ndpos}s/x.*/x=\"$dlgxpos\" y=\"$dlgypos\"\/>/" \
       -e "${ndsiz}s/width.*/width=\"${appdlg[0]}\" height=\"${appdlg[1]}\"\/>/" \
       -e "${nppos}s/x.*/x=\"$prfxpos\" y=\"$prfypos\"\/>/" \
       -e "${npsiz}s/width.*/width=\"${appprf[0]}\" height=\"${appprf[1]}\"\/>/" \
        $HOME/.config/labwc/rc.xml
