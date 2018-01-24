#! /usr/bin/env bash

set -e

install() {
    if [ -f "/usr/bin/launchenv" ]; then
        echo "Already installed."
        exit
    fi

    echo "Installing..."
    dirPart="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    scriptPart="$(basename $0)"
    sudo ln -s "$dirPart/$scriptPart" /usr/bin/launchenv
}

launch() {
    toRun=$1
    toPush=$2

    sudo docker pull $toRun
    x11docker --desktop --gpu --ps $toRun start
  
    image=$(sudo docker ps -a -q --filter=ancestor=$toRun)
  
    sudo docker commit $image $toPush
    sudo docker push $toPush
    sudo docker rm $image
}

if [ "$1"  == "install" ]; then
    install
elif [ "$1"  == "init" ]; then
    echo "Initializing environment..."
    launch $2 $3
else
    echo "Starting environment..."
    launch $1 $1
fi
