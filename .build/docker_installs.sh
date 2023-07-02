#!/bin/bash

clear

function install_docker() {
    wget https://github.com/WAGO/docker-ipk/releases/download/v1.0.5-beta/docker_20.10.14_armhf.ipk || return 1;
    opkg install docker_20.10.14_armhf.ipk || return 1; 
    rm docker_20.10.14_armhf.ipk;
}

case $1 in
    'docker')
        install_docker && printf "Docker v20.10.5 Installed." || printf "Error during installation. Check your internet connection and try again."
        ;;
    *)
        printf "Unknown command. Check source code."
        exit 1
        ;;
esac