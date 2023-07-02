#!/bin/bash

## Import files
source read_xml.sh

## Declare variables
declare initialMenu
declare selectedPLC
DIR="../res/xml"
isChild=0

function testXMLDir() {
    if [ -d "$DIR" ] ; then
        echo "XML directory found."
        if [ "$(ls -A $DIR)" ]; then
            echo "XML file(s) found."
            return 0
        else
            echo "Default XML directory ($DIR) is empty."
            return 1
        fi
    else
        echo "Default XML directory ($DIR) cannot be find."
        return 1
    fi
}

function askUserForXMLDir() {
    read -p "Enter location of XML files: " DIR
    if [ ! testXMLDir ] ; then
        echo "Given XML directory is invalid. Exiting program."
        exit
    fi
}

function readAllXMLFilesInDir() {
clear
local title=""
    
testXMLDir || askUserForXMLDir

for newFile in "$DIR"/*
    do
    [[ $newFile != *.xml ]] && continue         # Only check files with .xml extension
    echo "Creating menu file for: $newFile"
    getMenu "$newFile"
    [ -z "${menu[parent]}" ] && { initialMenu="${menu[id]}"; isChild=0; } || isChild=1
    title="$selectedPLC ${menu[title]}"
    echo "$(./generate_menu.sh "$title" $isChild "options" "${options[@]}" )" > "$TMPDIR/${menu[id]}".txt
done
sleep 1
clear
}