#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

HOGE=$(xrandr --query | grep " primary" | cut -d" " -f1)
echo $HOGE

# Launch Polybar, using default config location ~/.config/polybar/config
if type "xrandr"; then
    for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
        MONITOR=$m polybar main &
    done
else
    polybar main &
fi

echo "Polybar launched..."

