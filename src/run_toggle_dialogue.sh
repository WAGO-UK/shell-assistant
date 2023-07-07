#!/bin/bash

## function to create a temporary menu for toggling a value of a single variable
## and return a value back to the main function.

## TO DO:
## 1. Add proper command call and read return value
## 2. Dont expect Enable and Disable options - read them from file or get as parameter
## 3. static line numbers for enable, disable and back are not good either
## 4. test return value
## 5. clear unwanted lines and add more comments

## ========= Import files ============
source ./generate_menu.sh

## ===== Declare variables ===========
currOpt=0
declare focusedLine
enabled=false
enableLineNr=7
disableLineNr=8
backButton=9
lineOffset=7

read -r enLineNoTick  <<< $(generateToggle "Enable")
read -r disLineNoTick  <<< $(generateToggle "Disable")
enLineTick=$(sed "s/"'\[ ]'"/"'\[x]'"/" <<<"$enLineNoTick")
disLineTick=$(sed "s/"'\[ ]'"/"'\[x]'"/" <<<"$enLineNoTick")

## ===== Save parameters ===========
title="$1"
command="${@:2}"

function readFileAndHighlight() {
    highlight=$(( $currOpt + $lineOffset )) # Static for now; subject to change
    local n=1

    while read line; do
        ## Highlight
        if [ $n -eq $highlight ]; then
            echo -e "\e[42;97m$line\e[0m"
            focusedLine=$line
        else
            echo "$line"
        fi 
        ((n++))  
    done < $tempDir
}

function updateOptions() {
    ## Check if enabled
    if [ $enabled = true ]; then
        sed -i $enableLineNr"s/"'\[ ]'"/"'\[x]'"/" $tempDir
        sed -i $disableLineNr"s/"'\[x]'"/"'\[ ]'"/" $tempDir
    else
        sed -i $enableLineNr"s/"'\[x]'"/"'\[ ]'"/" $tempDir
        sed -i $disableLineNr"s/"'\[ ]'"/"'\[x]'"/" $tempDir
    fi   
}

function toggleOption() {
    [ "$highlight" -eq "$enableLineNr" ] && enabled=true
    [ "$highlight" -eq "$disableLineNr" ] && enabled=false
    [ "$highlight" -eq "$backButton" ] && (clear; echo "$enabled") && exit
}

## ========= Initalize ============
## Create temporary folder
mytemp=$(mktemp -d) || exit 1
trap 'rm -rf -- "$mytemp"' EXIT

## Run command
eval "$command" && enabled=true || enabled=false  ## in future replaced by $command result

## Save file directory and generate menu
tempDir="$mytemp/toggle_menu.txt"
echo "$(./generate_menu.sh "$title" 1 "toggle" )" > "$tempDir"

## Update current status and save into text file
updateOptions

## ========= Main Loop ============
while [ ans != "" ]; do 
{
    [ -f "$tempDir" ] && readFileAndHighlight "$fileDir" || echo "file does not exist!"
    escape_char=$(printf "\u1b")
    read -rsn1 ans # get 1 character
    [ "$ans" == "$escape_char" ] && read -rsn2 ans # read 2 more chars
    case $ans in
        'q') 
                clear ; echo "$enabled" ; exit ;;
        '[A') 
                [ "$currOpt" -gt 0 ] && ((currOpt--)) || currOpt=$optMax ;;
        '[B') 
                [ "$currOpt" -lt 2 ] && ((currOpt++)) ;;
        '[D')
                [ "$highlight" -eq "$backButton" ] && (clear; echo "$enabled") && exit ;;
        ''|'[C')     
                toggleOption
                updateOptions
                ;;
        *)      return ;;
    esac
}
done