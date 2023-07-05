#!/bin/bash

## Import files

## Create variables

## checkIfEmpty ( path )
function checkForConfig() {
    local FILE=".config"
    if [ "$(ls -A $FILE)" ]; then
    return 0
else
    return 1
fi
}

function checkForZip() {
    local FILE=shell-assistant.zip
    local DIR="~/"
    [ -f $DIR$FILE ] && return 0 || return 1
}

function cloneGithubRepo() {
    echo "WAGO Shell assistant couldn't be found on your device."
    read -p "Do you want to download latest version from Github? (Internet access required)"
    wget -P ~/ -O shell-assistant.zip https://github.com/WAGO-UK/shell-assistant/archive/master.zip
    checkForZip && unzip shell-assistant.zip -d ~/shell-assistant
    rm ~/shell-assistant.zip
}

## Check if config file already exist
checkForConfig && echo "all good" || cloneGithubRepo


## check if command "wsa" is found

## pull zip file from github and unzip it

## Ask user if to keep the files after exit or delete them
## (optional) create temp folder and trap it
## pull files from github repo                                          # everything accept xml files for specific controller
## (optional) create a settings file to retain main values              # remember to keep text files in main rather than deleting them (speeds up the process) - TBC


## check if xml files are available in /src

## run /res/main.sh script

## (optional) wait till finishes and clean after

## (optional) wait till finishes and save new settings

## (optional) associate wsa command
