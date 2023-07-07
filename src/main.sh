#!/bin/bash

## Import files
source ./read_xml.sh
source ./initialise_menu.sh

## Declare variables
declare lastMenuID
declare optMax
declare -A selectedOptAttribs
currOpt=0

function readFileAndHighlight() {
    local FILE="$1"
    local highlight=$(( $2 + 7 )) # Static for now; subject to change
    local n=1

    while read line; do
        [ $n -eq $highlight ] && echo -e "\e[42;97m$line\e[0m" || echo "$line"   
        ((n++))  
    done < $FILE
}

function readFileAndHighlightNew() {
    local FILE="$1"
    local highlight=$(( $2 + 7 ))

    echo -e "$(sed $highlight's/'"\*"'/'"\e[42;97m"'/' "$FILE" )"
}

function updateCurrentMenu() {
    local txtFilePath="$TMPDIR/$1.txt"
    local xmlFilePath="$XMLDIR/$1.xml"
    if [ -f "$txtFilePath" ] && [ -f "$xmlFilePath" ] ; then
        lastMenuID="${menu[id]}"
        srcFile="$txtFilePath"
        getMenu "$xmlFilePath" || { echo "XML file is not available!"; return 1; }
        optMax=${#options[@]}
        [ -z "${menu[parent]}" ] && ((optMax--)) 
    else
        return 1
    fi
}

## Used for testing
function finalAttributeLoop() {
    for key in "${!my_array[@]}"; do
        echo "$key ${my_array[$key]}"
    done
}

function saveAttributes() {
    local name
    local value
    local rawString="$@"
    local len=${#rawString}
    local i=0
    [ -z "$rawString" ] && return 1
    while [ "$rawString" ] && [ $i -lt $len ]; do
        shopt -s extglob    # Turn on the extglob shell option 
        rawString="${rawString##*( )}" && rawString="${rawString%%*( )}" #trim leading and trailing whitespaces
        shopt -u extglob    # Turn off
        name=${rawString%%=\'*}
        rawString=${rawString#*=\'}
        value=${rawString%%\'*}
        rawString=${rawString#*\'}
        selectedOptAttribs[$name]="$value"
        ((i++))
    done   
}

function updateMenu() {
    saveAttributes "${attributes[$currOpt]}" || selectedOptAttribs[type]="back"
    #finalAttributeLoop
    case "${selectedOptAttribs[type]}" in
        "submenu")
                    updateCurrentMenu "${selectedOptAttribs[id]}" || echo "cannot update the menu."
                    ;;
        "endpoint")
                    cd $BUILDDIR
                    eval "${selectedOptAttribs[command]}"
                    cd $SRCDIR
                    sleep 1
                    ;;
        "device")
                    echo "Device selected: ${options[$currOpt]}"
                    selectedPLC=$( echo "${options[$currOpt]}" | tr '[:upper:]' '[:lower:]' )
                    sleep 1
                    XMLDIR="$XMLDIR/$selectedPLC"
                    readAllXMLFilesInDir || exit
                    updateCurrentMenu "${selectedOptAttribs[id]}" || echo "cannot update the menu."
                    ;;
        "toggle")
                    # using run_toggle_dialogue
                    ./run_toggle_dialogue.sh "${menu[title]}" "${selectedOptAttribs[command]}"
                    ;;
        "back")
                    updateCurrentMenu "${menu[parent]}" || echo "cannot update the menu."
                    ;;
        *)
                    echo "wrong input; try again"
                    exit
                    ;;
    esac
}

## ========= Initialize ============
## Temporary folder directory & generation of xml files
TMPDIR=$(mktemp -d) || exit
trap 'rm -rf -- "$TMPDIR"' EXIT

## Read first set of XML files (device)
readAllXMLFilesInDir || exit

## set currentMenu variable to the first menu in xml chain
updateCurrentMenu $initialMenu || exit 

## ========= Main Loop ============
while [ ans != "" ]; do 
{
    [ -f $srcFile ] && readFileAndHighlight "$srcFile" $currOpt || echo "file does not exist!"
    escape_char=$(printf "\u1b")
    read -rsn1 ans # get 1 character
    [ "$ans" == "$escape_char" ] && read -rsn2 ans # read 2 more chars
    case $ans in
        'q') 
                echo QUITTING ; exit ;;
        '[A')   # UP arrow key
                [[ $currOpt -gt 0 ]] && ((currOpt--)) || currOpt=$optMax ;;
        '[B')   # DOWN arrow key 
                [[ $currOpt -lt $optMax ]] && ((currOpt++)) ;;
        '[D')   # LEFT arrow key
                updateCurrentMenu "${menu[parent]}" || echo "cannot update the menu." ;;
        ''|'[C') # Enter or RIGHT arrow key    
                updateMenu
                currOpt=0 ;;
        *)      continue ;;
    esac
}
done