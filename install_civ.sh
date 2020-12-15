#!/bin/bash

# Bail out if any command fails
set -e

# Check that a username/password was supplied
if [ $# -ne 2 ]; then
    printf "Usage: $0 <steam_username> <steam_password>\n"
    exit 1
fi

mkdir -p temp

# If the container already exists, trash it first
docker container rm -v civ5server_steamcmd || true

printf ":: Installing Civ 5 and Civ 5 SDK\n"

docker run \
    --name civ5server_steamcmd \
    -it \
    -v $PWD:/data steamcmd/steamcmd:latest \
    +@sSteamCmdForcePlatformType windows \
    +login "$1" "$2" \
    +force_install_dir /data/civ5game \
    +app_update 8930 \
    +force_install_dir /data/temp \
    +app_update 16830 \
    +quit

# Docker files will be owned by root, which means we won't be able to copy the dedicated server files over unless if we
# own them first
if [ "$EUID" -ne 0 ]; then
    printf ":: Taking ownership of installed files\n"
    sudo chown -R "$USER" civ5game temp
fi

printf ":: Moving dedicated server files to the Civ 5 install\n"

mv "temp/Dedicated Server/"* civ5game

printf ":: Cleaning up SDK install and SteamCMD Docker container\n"

rm -r temp
docker container rm -v civ5server_steamcmd
