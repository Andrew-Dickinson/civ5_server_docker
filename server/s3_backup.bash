#!/bin/bash

set -x
set -e

while : ; do
echo "Backing up..."
aws s3 sync "/root/My Games/Sid Meier's Civilization 5/Saves" $SAVES_BACKUP_S3_PATH
sleep 60
done

