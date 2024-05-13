[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

# gog-linux-docker-script

A script to run a GOG game in a Docker container.

## > Description

This script creates Docker container to run GOG games, providing isolation and dependency management. Each game runs in its own container with the necessary runtime environment.

## > Concise Instructions

### Start
1. Copy one GOG game for GNU/Linux OS (with DLCs) in the project folder,
2. move to the project folder and
3. run './project.sh start'.

> [!CAUTION]
> You can put only one game (with all DLCs and extras) in the project folder.

### Remove generated files and folders
1. Clean up with './project.sh clean'.
