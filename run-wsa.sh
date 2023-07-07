#!/bin/bash

## Import files

## Create variables
zipFile="shell-assistant-main.zip"
sa="shell-assistant-main"
DIR="$(pwd)"
declare MENUTMPDIR

function welcomeUser() {
    local decision=""
    clear
    echo "Welcome to WAGO Shell Assistant!"
    echo "We have recognised this is your first start"
    ## Ask user if to keep the files after exit or delete them
    read -p "Would you like to save settings for future use or clear all files once done? [(S)ave / (C)lear]" decision
    decision=$( echo "$decision" | tr '[:upper:]' '[:lower:]' )
    case $decision in
    "s"|"save")
                    checkForZip || promptUserToDownload ;;
    "c"|"clear"|"cl") 
                    createTempFolder
                    DIR=$MENUTMPDIR 
                    checkForZip || promptUserToDownload ;;
    *)
                    echo "Invalid input; try again." ;;
    esac    
}

## (optional) create temp folder and trap it
function createTempFolder() {
    MENUTMPDIR=$(mktemp -d) || exit
    trap 'rm -rf -- "$MENUTMPDIR"' EXIT
}

function checkForZip() {
    [ -f "$zipFile" ] || return 1
    [ ! "$DIR" = "$(pwd)" ] && { cp "$zipFile" "$DIR" ; cd "$DIR" ; }
        unzip "$zipFile" || { echo "zip file could not be found." ; exit ; }
    #rm "$zipFile"
}

function promptUserToDownload() {
    local decision=""
    echo "WAGO Shell Assistant couldn't be found on your device."
    read -p "Do you want to download latest version from Github? (Internet access required) [(Y)es / (N)o]" decision
    echo "$decision"
    decision=$( echo "$decision" | tr '[:upper:]' '[:lower:]' )
    case $decision in
    "y"|"yes")
                    cloneGithubRepo ;;
    "n"|"no")
                    echo "Copy repository from WAGO-UK GitHub or try again later."
                    exit;;
    *)
                    echo "Invalid input; try again." ;;
    esac              
}

## pull zip file from github and unzip it
function cloneGithubRepo() {                                      
    wget -P "$DIR" -O "$zipFile" https://github.com/WAGO-UK/shell-assistant/archive/master.zip || internetErrorMsgShow 
    checkForZip
}

function internetErrorMsgShow() {
    echo "Couldn't connect to internet or pull directory. Check WAGO-UK GitHub account for more details."
    exit
}

function setFilePermissions() {
    #cd $DIR/$a
    #chmod 777 src       # set execute permissions - not working 
    #chmod 777 .build    # set execute permissions - not working
    
    ## Assigning permissions to files in .build folder
    cd $DIR/$sa/.build
    local files=($(ls -d *))
    chmod +x "${files[@]}"

    ## Assigning permissions to files in src folder
    cd $DIR/$sa/src
    local files=($(ls -d *))
    chmod +x "${files[@]}"
}

## Check if main file already exists
[ "$(ls -A $DIR/$sa)" ] || welcomeUser                   

## set execute permissions for certain files in DIR
setFilePermissions

## run /src/main.sh script
cd $DIR/$sa/src && sh main.sh

## check if command "wsa" is found

## (optional) create a settings file to retain main values              # remember to keep text files in main rather than deleting them (speeds up the process) - TBC

## (optional) wait till finishes and save new settings

## (optional) associate wsa command
