#!/usr/bin/bash

declare -A list=(
  ['Logout']='xdotool key Super+shift+q'
  #['Poweroff']='xmonad --recompile; systemctl poweroff'
  ['Poweroff']='systemctl poweroff'
  #['firefpx']='firefox'
  #['Reboot']='xmonad --recompile; systemctl reboot'
  ['Reboot']='systemctl reboot'
)

if [[ ${1##* } == 'yes' ]]; then
  eval ${list[${1%% *}]}
elif [[ ${1##* } == 'no' ]]; then
  echo ${!list[@]} | sed 's/ /\n/g'
elif [[ -n $1 ]]; then
  echo "$1 / no"
  echo "$1 / yes"
else
  echo ${!list[@]} | sed 's/ /\n/g'
fi

