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
PROJECT_LANG=$LANG

clean() {

  docker compose down -v --rmi all --remove-orphans
  rm -rf GOG\ Games/ \
    docker-compose.yml \
    Dockerfile

}

start() {

  if [[ ! -f Dockerfile ]]; then
    touch Dockerfile && \
    cat <<EOF> Dockerfile
  FROM debian:bookworm

  ENV DEBIAN_FRONTEND=noninteractive
  ENV USER=$USER

  RUN apt-get update && \
    apt-get install -y \
    gtk2-engines \
    gtk2-engines-pixbuf \
    gtk2-engines-murrine \
    libasound2-data \
    libasound2 \
    libasound2-plugins \
    libc6 \
    libcanberra-gtk-module \
    libcurl4 \
    libegl1-mesa \
    libgconf-2-4 \
    libgl1-mesa-dri \
    libgl1-mesa-glx \
    libglapi-mesa \
    libgles2-mesa \
    libgtk2.0-0 \
    libnss3 \
    libpng16-16 \
    libpng-dev \
    libxml2 \
    libxt6 \
    libxtst6 \
    libudev-dev \
    locales \
    locales-all \
    mesa-opencl-icd \
    mesa-va-drivers \
    mesa-vdpau-drivers \
    sudo \
    dosbox

  ENV LC_ALL $PROJECT_LANG
  ENV LANG $PROJECT_LANG
  ENV LANGUAGE $PROJECT_LANG

  RUN groupadd -g $PROJECT_GID -r $USER
  RUN useradd -u $PROJECT_UID -g $PROJECT_GID --create-home -r $USER

  #Change password
  RUN echo "$USER:$USER" | chpasswd
  #Make sudo passwordless
  RUN echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-$USER
  RUN usermod -aG sudo $USER
  RUN usermod -aG plugdev $USER

  USER $USER

  WORKDIR /home/$USER
EOF
fi

if [[ ! -f docker-compose.yml ]]; then
  touch docker-compose.yml
  cat <<EOF> docker-compose.yml
  services:
    gogplay:
      build: .
      user: $PROJECT_UID:$PROJECT_GID
      environment:
        DISPLAY: $DISPLAY
        XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR
      working_dir: "/home/$USER"
      volumes:
        - /tmp/.X11-unix:/tmp/.X11-unix
        - /run/user/${PROJECT_UID}:/run/user/${PROJECT_UID}
        - .:/home/$USER/source
        - "./GOG\ Games:/home/$USER/GOG\ Games"
      devices:
        - /dev/snd:/dev/snd
        - /dev/dri:/dev/dri
EOF
fi

## if GOG Games doesn't exist, search for .sh files, make them executable and install them

  if [[ ! -d GOG\ Games ]]; then
    mkdir -p GOG\ Games 
    find ./* -maxdepth 0 -name "*.sh" -exec chmod +x {} +
    find ./* -maxdepth 0 -name "*.sh" ! -name "project.sh" -exec docker compose run --rm gogplay sh -c 'cd /home/$USER/source && ./{}' \;
  fi

## Find start.sh and run it

  find ./* -name "start.sh" -exec docker compose run --rm gogplay sh -c \'{}\' \;

}

"$1"
