#!/bin/bash

## Check if OS is GNU/Linux

if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "Script runs only on GNU/Linux OS. Exiting..."
    exit
fi

## Check if Docker compose plugin is installed

if [[ ! -x "$(command -v compose version)" ]]; then
    echo "Compose plugin is not installed. Exiting..."
    exit
fi

## Variables

PROJECT_UID=$(id -u)
PROJECT_GID=$(id -g)
PROJECT_LANG=$LANG

"$1"
