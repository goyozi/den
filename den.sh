#! /usr/bin/env bash

set -e

install() {
    if [ -f "/usr/bin/den" ]; then
        printf "\033[0;33mAlready installed.\033[0m\n"
        exit
    fi

    if [ ! -f den.sh ]; then
        printf "\033[0;31mYou must run the installation from den's source directory.\033[0m\n"
        exit 1
    fi

    dirPart="$(pwd)"
    ln -s "$dirPart/den.sh" /usr/bin/den

    printf "\033[0;32mInstalled.\033[0m\n"
}

remove() {
    if [ ! -f "/usr/bin/den" ]; then
        printf "\033[0;33mNot installed.\033[0m\n"
        exit
    fi

    rm /usr/bin/den
    printf "\033[0;32mRemoved.\033[0m\n"
}

set_linux_defaults() {
    STARTX_OPTS=${STARTX_OPTS:="-- :1 vt8"}
    XHOST_OPTS=${XHOST_OPTS:="+local:"}
    DISPLAY=${DISPLAY:="\$DISPLAY"}
}

set_cygwin_defaults() {
    STARTX_OPTS=${STARTX_OPTS:="-- :0 -listen tcp -fullscreen -keyhook"}
    DETECTED_LOCAL_IP=$(getent ahostsv4 $(hostname) | awk '{ print $1 }' | head -1)
    LOCAL_IP=${LOCAL_IP:=$DETECTED_LOCAL_IP}
    XHOST_OPTS=${XHOST_OPTS:="+ $LOCAL_IP"}
    DISPLAY=${DISPLAY:="$LOCAL_IP:0"}
}

launch() {
    toRun=$1
    toPush=$2

    containerName=den_$(echo "$toPush" | tr / _)

    container=$(docker ps -a -q --filter=name=$containerName)

    if [ -n "$container" ]; then
        printf "\
\033[0;31mERROR! Environment container exists!
It's possible that den has not exited properly the last time it was ran.
You need to commit and push your progress (if needed) and remove the container manually.
\033[0m"
        exit 1
    fi

    mkdir -p /tmp/den

    docker pull $toRun

    unameOut="$(uname -s)"
    case "${unameOut}" in
        CYGWIN*)    set_cygwin_defaults;;
        *)          set_linux_defaults
    esac

    echo "STARTX_OPTS: $STARTX_OPTS"
    echo "XHOST_OPTS: $XHOST_OPTS"
    echo "DISPLAY: $DISPLAY"

    echo "
        xhost $XHOST_OPTS
        docker run --name $containerName \\
                   -e DISPLAY=$DISPLAY \\
                   -v /tmp/.X11-unix:/tmp/.X11-unix:rw \\
                   $DOCKER_OPTS \\
                   $toRun > /tmp/den/container.log 2>&1
    " > /tmp/den/xinitrc

    export XAUTHORITY=/tmp/den/Xauthority

    startx /tmp/den/xinitrc $STARTX_OPTS
  
    docker commit $containerName $toPush
    docker push $toPush
    docker rm $containerName
}

if [ "$1"  == "install" ]; then
    install
elif [ "$1"  == "remove" ]; then
    remove
elif [ "$1"  == "init" ]; then
    echo "Initializing environment $3 using $2..."
    launch $2 $3
elif [ "$1"  == "start" ]; then
    echo "Starting environment $2..."
    launch $2 $2
else
    echo "You must specify a command."
fi
