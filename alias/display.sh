#!/bin/bash

# このコマンド xmonad.hs で参照してる


disp=`xrandr | awk '{ if ($2 == "connected") print $3 == "primary" ? "p" : "n", $1, $3 == "primary" ? $4 : $3 }'`

if [ $# -eq 1 ]; then
    if [ $1 = "auto" ]; then
        disp=`xrandr | awk 'BEGIN { flag = 1 } $2 == "connected" && NR > 2 && flag == "1" {print $1; flag = 0 }'`
    else
        disp=$1
    fi
    # --right-of --left-of --above --below
    xrandr --output eDP1 --auto --primary --output $disp --auto --left-of eDP1
    #xrandr --output eDP1 --auto --output $disp --auto --primary --right-of eDP1
    nitrogen --restore

elif [ $# -eq 2 ]; then
    if [ $1 = "off" ]; then
        if [ $2 = "auto" ]; then
            disp=`xrandr | awk 'BEGIN { flag = 1 } $2 == "connected" && NR > 2 && flag == "1" {print $1; flag = 0 }'`
        else
            disp=$2
        fi
        xrandr --output $disp --off
    fi
fi

