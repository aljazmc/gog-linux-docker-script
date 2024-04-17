#!/bin/bash

## Variables

PROJECT_UID=$(id -u)
PROJECT_GID=$(id -g)
PROJECT_LANG=$LANG

"$1"
