# gog-linux-docker-script
A script to run GNU/Linux GOG game in a Docker container.

## > Requirements:

* GNU/Linux operating system
* docker with docker compose plugin

## > Basic usage:

* clone the project with:
```
git clone https://github.com/aljazmc/gog-linux-docker-script
```
* move to gog-linux-docker-script directory with:
```
cd gog-linux-docker-script
```
* copy the GOG's "*.sh" file(s) into the gog-linux-docker-script folder. 

> [!CAUTION]
> You could put only one game (with all DLCs and extras) in this folder.

* install and start the game with:
```
./project.sh start
```
* after intense gaming session you may want to clean up the directory and remove docker files with:
```
./project.sh clean
```

## > LICENSE: [MIT](https://github.com/aljazmc/gog-linux-docker-script/blob/main/LICENSE)
