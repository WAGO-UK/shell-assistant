#!/bin/bash

# TO DO:
# - add function to save attributes

declare -A menu
declare -a attributes
declare -a options

xmlFileLocation="./xml/"
declare file

function cleanUpEntityString() {
    local rawString="$ENTITY"
    local tmp=${rawString#* }

}

# readDom( )
function readDom() {
    local IFS=\>
    read -d \< ENTITY CONTENT
}
# extractData( )
function extractData() {
    menu=[]
    options=()
    attributes=()
    while readDom; do
        ## comparator checks if entity contains a phrase
        case $ENTITY in
        "title")
            menu[title]="$CONTENT"
            ;;
        "parent")
            menu[parent]="$CONTENT"
            ;;
        "id")
            menu[id]="$CONTENT"
            ;;
        "option"*)
            options+=( "$CONTENT" )
            attributes+=( "${ENTITY#* }" ) # used to strip initial 'option' out of the string
            ;;
        *)
            ;;
        esac
    done < $FILE
}

# getMenu( filename )
function getMenu() {
    FILE="$1"
    [[ -f $FILE ]] && extractData ||  exit 1 
}


############################################
# How to loop through keys & values in menu:
#for key in "${!menu[@]}"; do
#    echo "$key ${menu[$key]}"
#done
############################################