#!/bin/bash

find . -type f -regex ".*\.\(cpp\|hpp\)" | xargs grep -n $1 | awk '{print $1; printf "   >> "; for (i = 2; i < NF; i++) printf $i; print $NF;}'

