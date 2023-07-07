#!/bin/bash

declare version

function install_docker() {
    version="v20.10.5"
    wget https://github.com/WAGO/docker-ipk/releases/download/v1.0.5-beta/docker_20.10.14_armhf.ipk || return 1;
    opkg install docker_20.10.14_armhf.ipk || return 1; 
    rm docker_20.10.14_armhf.ipk;
}

function install_node_red() {
    docker volume create --name node_red_user_data || { echo "Error during volume creation. Is Docker daemon running?" ; return 1 ; }
    docker run -d -p 1880:1880 --network host --privileged=true --u root --restart=unless-stopped --name node-red -v node_red_user_data:/data nodered/node-red:latest || return 1;
}

function install_mosquitto() {
    version="1.5"
    docker run -d --restart unless-stopped --name mosquitto --network=host eclipse-mosquitto:1.5; || return 1
}

function install_kbus_modbus() {
    docker run -d --init --restart unless-stopped --privileged -p 502:502 --name=pfc-modbus-server -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket wagoautomation/pfc-modbus-server; || return 1
}

function install_grafana() {
    docker volume create grafana-storage || { echo "Error during volume creation. Is Docker daemon running?" ; return 1 ; }
    docker run -d --restart unless-stopped --network host --name=grafana -v grafana-storage:/var/lib/grafana grafana/grafana; || return 1
}

function install_influxdb() {
    docker run -d --restart unless-stopped --name=influxdb --network=host -v influx-storage:/etc/influxdb/ arm32v7/influxdb; || return 1
}

function install_kbus_daemon() {
    docker run -d --init --restart unless-stopped --privileged --network=host --name=kbus -v kbusapidata:/etc/kbus-api -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket jessejamescox/pfc-kbus-api ; || return 1
}

function install_portainer() {
    echo "oopss.. command not found.."
    return 1
}

function printError(){
    printf "Error during installation. Check your internet connection and try again."
    exit 1
}


clear

case $1 in
    'docker')
        install_docker || printError
        ;;
    'node-red')
        install_node_red || printError
        ;;
    'mosquitto')
        install_mosquitto || printError
        ;;
    'kbus-modbus')
        install_kbus_modbus || printError
        ;;
    'grafana')
        install_grafana || printError
        ;;
    'influxdb')
        install_influxdb || printError
        ;;
    'kbus-daemon')
        install_kbus_daemon || printError
        ;;
    'portainer')
        install_portainer || printError
        ;;
    *)
        printf "Unknown command. Check source code."
        exit 1
        ;;
esac
printf "$1 $version installed."