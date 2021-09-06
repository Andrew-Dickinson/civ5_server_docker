#!/bin/bash

# Bail out if any command fails
set -e

# Fetch the dir where this bash script is
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

#### Ports ####
# 5900 TCP: VNC
# 27016 UDP: Civ 5 pitboss

# We only accept VNC connections from `127.0.0.1` - to access it, set up an ssh tunnel with
# `ssh -L 5900:localhost:5900 user@example.com`

# Run our built container
docker run \
    --env-file "$DIR/env_file.txt" \
    --mount type=bind,source="$DIR/civ5game",target="/root/civ5game" \
    --mount type=bind,source="$DIR/civ5save",target="/root/My Games/Sid Meier's Civilization 5" \
    -p 127.0.0.1:5900:5900/tcp \
    -p 27016:27016/udp \
    civ5server
