#! /usr/bin/env bash

set -e

install() {
    if [ -f "/usr/bin/den" ]; then
        echo "Already installed."
        exit
    fi

    if [ ! -f den.sh ]; then
        echo "You must run the installation from den's source directory."
        exit 1
    fi

    dirPart="$(pwd)"
    ln -s "$dirPart/den.sh" /usr/bin/den

    echo "Installed."
}

launch() {
    toRun=$1
    toPush=$2

    mkdir -p /tmp/den

    docker pull $toRun
    
    echo "
        xhost +local:
        docker run -e DISPLAY=\$DISPLAY \\
                   -v /tmp/.X11-unix:/tmp/.X11-unix:rw \\
                   $DOCKER_OPTS \\
                   $toRun > /tmp/den/container.log
    " > /tmp/den/xinitrc

    startx /tmp/den/xinitrc
      
    image=$(docker ps -a -q --filter=ancestor=$toRun)
  
    docker commit $image $toPush
    docker push $toPush
    docker rm $image
}

if [ "$1"  == "install" ]; then
    install
elif [ "$1"  == "remove" ]; then
    rm /usr/bin/den
elif [ "$1"  == "init" ]; then
    echo "Initializing environment $3 using $2..."
    launch $2 $3
elif [ "$1"  == "start" ]; then
    echo "Starting environment $2..."
    launch $2 $2
else
    echo "You must specify a command."
fi
