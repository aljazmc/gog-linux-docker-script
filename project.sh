#!/bin/bash

## Check if OS is GNU/Linux

if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "Script runs only on GNU/Linux OS. Exiting..."
    exit
fi

## Check if Docker compose plugin is installed

if ! docker compose version >/dev/null 2>&1; then
    echo "Compose plugin is not installed. Exiting..."
    exit
fi

## Variables

PROJECT_UID=$(id -u)
PROJECT_GID=$(id -g)

clean() {

    if [[ -f docker-compose.yml ]]; then
        docker compose down -v --rmi all --remove-orphans
    fi
    find . -mindepth 1 -maxdepth 1 \
        ! -name ".git" \
        ! -name ".gitignore" \
        ! -name "LICENSE" \
        ! -name "README.md" \
        ! -name "printscreen.png" \
        ! -name "*.sh" \
        -exec rm -rf {} +

}

start() {

## Check for other .sh files than project.sh in the project folder or quit

if find ./* -maxdepth 0 -type f -name "*.sh" ! -name "project.sh" -exec false {} + ; then
    echo "No .sh file found. Exiting..."
    exit 1
fi

if [[ ! -f docker-compose.yml ]]; then
    touch docker-compose.yml
    cat <<EOF> docker-compose.yml
services:
    gogplay:
        image: aljazmc/x11-debian
        user: $(id -u):$(id -g)
        working_dir: /home/x11
        volumes:
            - .:/home/x11
            - /home/$USER/.Xauthority:/home/x11/.Xauthority
            - /run/user/$(id -u):/run/user/1000
            - /tmp/.X11-unix:/tmp/.X11-unix
            - /var/lib/dbus/machine-id:/var/lib/dbus/machine-id
        devices:
            - /dev/dri:/dev/dri
            - /dev/snd:/dev/snd
        environment:
            DISPLAY: $DISPLAY
            HOME: /home/x11
            XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR
        network_mode: host
EOF
fi

## if GOG Games doesn't exist, search for .sh files, make them executable and install them

  if [[ ! -d GOG\ Games ]]; then
    mkdir -p GOG\ Games 
    find ./* -maxdepth 0 -name "*.sh" -exec chmod +x {} +
    find ./* -maxdepth 0 -name "*.sh" ! -name "project.sh" -exec docker compose run --rm gogplay sh -c 'cd /home/x11 && ./{}' \;
  fi

## Find start.sh and run it

  find ./* -name "start.sh" -exec docker compose run --rm gogplay sh -c \'{}\' \;

}

case "$1" in
    start|clean)
        "$1"
        ;;
    *)
        echo "Usage: ./project.sh {start|clean}"
        exit 1
        ;;
esac
