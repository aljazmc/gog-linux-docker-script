#!/bin/bash

## Check if OS is GNU/Linux

if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "Script runs only on GNU/Linux OS. Exiting..."
    exit
fi

## Check if Docker compose plugin is installed

if [[ ! -x "$(command -v compose)" ]]; then
    echo "Compose plugin is not installed. Exiting..."
    exit
fi

## Check for other .sh files than project.sh in the project folder or quit

if find ./* -maxdepth 0 -type f -name "*.sh" ! -name "project.sh" -exec false {} + ; then
    echo "No .sh file found. Exiting..."
    exit
fi

## Variables

PROJECT_UID=$(id -u)
PROJECT_GID=$(id -g)

clean() {

    docker compose down -v --rmi all --remove-orphans
    rm -rf GOG\ Games/ \
        docker-compose.yml

}

start() {

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

"$1"
