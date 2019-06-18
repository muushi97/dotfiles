#!/bin/bash

ls -R1l $1 | grep -v ^d | grep ^- | awk '{for(i=9;i<NF;i++){printf("%s ",$i)}print $NF}' | sort

