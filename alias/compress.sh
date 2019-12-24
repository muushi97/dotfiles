#!/bin/sh

if [[ $1 == "-c" ]]; then
    if [[ $3 == "tar.gz" ]]; then
        tar -zcvf ${2}.$3 $2
    elif [[ $1 == "tar.bz2" ]]; then
        tar -jcvf ${2}.$3 $2
    elif [[ $1 == "tar.xz" ]]; then
        tar -Jcvf ${2}.$3 $2
    elif [[ $1 == "tar" ]]; then
        tar -cvf ${2}.$3 $2
    elif [[ $1 == "zip" ]]; then
        zip -r ${2}.$3 $2
    fi
elif [[ $1 == "-x" ]]; then
    tar -xvf $2
    # unar $2
fi


