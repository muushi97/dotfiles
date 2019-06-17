#!/bin/bash

if [ $(fcitx-remote) = "1" ]; then
  echo "_A"
elif [ $(fcitx-remote) = "2" ]; then
  echo "あ"
else
  echo "__"
fi

