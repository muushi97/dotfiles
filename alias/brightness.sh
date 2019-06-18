#!/bin/bash

# 輝度調整用

#        : 現在の輝度をパーセント表示
# -s PER : 輝度PER％に設定

set_option="-s"

if [ "$1" = "$set_option" ]; then
	# 輝度設定
	if [ $2 -le 100 ] && [ $2 -ge 0 ]; then
		max=`sudo cat /sys/class/backlight/intel_backlight/max_brightness`
		next=$(($2 * $max / 100))
		echo "$next" | sudo tee /sys/class/backlight/intel_backlight/brightness > /dev/null
	fi

else
	# 現在輝度
	max=`sudo cat /sys/class/backlight/intel_backlight/max_brightness`
	now=`sudo cat /sys/class/backlight/intel_backlight/brightness`
	echo $(( ($now * 100 + ($max / 2)) / $max ))"%"
fi

