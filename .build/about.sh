#!/bin/bash

aboutFileDir="../res/about.txt"

clear

if [ -f "$aboutFileDir" ] ; then
    while read line; do 
        echo -e "$line"
    done < $aboutFileDir
fi
read -n 1 -s -r -p "Press any key to return..."