#!/bin/bash

## Quick notes:
## - check tput for inputing colours; example = lightblue=$(tput setaf 123)
## - optimise generateText option for shorter execution (PRIORITY)

## include xml file script
source read_xml.sh

## Configuration
symbol="*"
padding_symbol=" "
padding_size=4
line_size=70
border_width=1

declare border
declare empty_line
declare -i longest_text

## user variables
title="$1"              ## string to appear in menu header
childMenu=$2            ## 0 = no parent, 1 = parent exists
type="$3"               ## see body function for more details
options=("${@:4}")      ## array of options to display in the menu

## checkWidth( options(array) )
function checkWidth() {
    local size=0
    ## get length of $options array
    local len=${#options[@]}
    for (( i=0; i<$len; i++ )); do 
        local item=${options[i]}
        ## compare current value to last
        [[ ${#item} -gt size ]] && size=${#item}
    done
    echo $size
}

## header ( title )
function header() {
    ## generate known lines
    border=$(generateBorder)
    empty_line=$(generateText)  
    ## echo header
    echo "$border"
    echo "$empty_line"
    generateText "header" "$title"
    echo "$empty_line"
    echo "$border"
}

## body ( options(array) )
function body() {
    echo "$empty_line"
    case $type in
        "options")
            [ -n "$options" ] && generateOptions ;;
        "toggle")
            generateToggle "Enable" 
            generateToggle "Disable";;
        *)
            generateText "error" "Error - no type has been selected when generating this menu.";;
    esac

    [[ $childMenu -eq 1 ]] && generateBackButton
    echo "$empty_line"
    echo "$border"
}

function footer() {
    generateMenuFooter
    echo "$border"
}

## generatePadding( amount )
function generatePadding() {
    local string=""
    for (( i=0; i < $1; i++ )); do
        string+="$padding_symbol";
    done
    printf "$string"
}

function generateBorder() {
    local string=""
    for (( i=0; i < line_size; i++ )); do
      string+="$symbol";
    done
    ## echo the result
    echo -e "$string"
}

## generateText ( type, text )
function generateText() {
    local characters=$(( $line_size - $border_width*2))
    [ "$1" = "header" ] && local padding=$(( ($characters - ${#2} ) / 2 )) || local padding=$padding_size
    ## set up remaining padding
    local padding_remaining=$(( $characters - $padding - ${#2}))
    local padLeft=$(generatePadding $padding)
    local padRight=$(generatePadding $padding_remaining)
    ## echo the result
    printf "$symbol$padLeft$2$padRight$symbol\n"
}

## generateOptions( options(array) )
function generateOptions() {
    local index=1
    for item in "${options[@]}"; do
        generateText "options" "$index. $item"
        ((index++))
    done
}

## generateToggle ( text )
function generateToggle() {
    generateText "toggle" "[ ]  $1"
}

function generateBackButton() {
    generateText "back" "< Back.."
}

function generateMenuFooter() {
    generateText "footer" "Move: ARROW UP/DOWN      |    Select: ENTER"
    generateText "footer" "Back: ESCAPE             |    Quit:   Q"  
}

## generateMenu( )
function generateMenu() {
    clear
    header
    body  
    footer
    #longest_text=$(checkWidth "${options[@]}")
}

## Main
 [ -n "$title" ] && [ -n "$type" ]  && generateMenu