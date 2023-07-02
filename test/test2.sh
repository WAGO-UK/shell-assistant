#!/bin/bash

declare -A result

function saveAttributes() {
    local name
    local attrib
    local value
    IFS=' ' read -ra my_array <<< "$@"
    for item in "${!my_array[@]}"; do
        attrib="${my_array[$item]}"
        [[ "$attrib" == *=* ]] || continue
        name=${attrib%=*}
        value=${attrib#*=\'} 
        [[ "$value" == *\>* ]] && value=${value%\'\>} || value=${value%\'}
        result["$name"]="$value"
    done
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

## TO do:
#- start from left and take down string piece by piece
#- everytime '=' is found, what's to its left is a name,
#- what's to its right is temp value, but limited to next occurence of '
#- strip out space and move on to next one
#- delete what was processed and continue until string is null (while loop)


function saveAttributesTwo() {
    local name
    local value
    local tmp
    local rawString="$@"


    while [[ $rawString ]]; do
        shopt -s extglob
        rawString="${rawString##*( )}" && rawString="${rawString%%*( )}" #trim leading and trailing whitespaces
        shopt -u extglob
        name=${rawString%%=\'*}
        rawString=${rawString#*=\'}
        value=${rawString%%\'*}
        rawString=${rawString#*\'}
        result[$name]="$value"
    done
}

init="type='endpoint' command='echo Hi there!'"
echo $init

saveAttributesTwo $init

for key in "${!result[@]}"; do
    echo "$key ${result[$key]}"
done

echo "${result[command]}"
