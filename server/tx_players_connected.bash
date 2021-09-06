#!/bin/bash

set -e
set -x

CIV_DATA_ROOT="/root/My Games/Sid Meier's Civilization 5"
INSTANCE_ID=$(curl "http://169.254.169.254/latest/meta-data/instance-id/")

while : ; do
    if [[ $(netstat -au | grep 0.0.0.0:27016) ]] ; then
        if [ -f "$CIV_DATA_ROOT/ModUserData/PlayersConnected-1.db" ]; then
            CONNECTED_PLAYERS=$(sqlite3 "$CIV_DATA_ROOT/ModUserData/PlayersConnected-1.db" "SELECT Value FROM SimpleValues WHERE Name = 'PlayersConnected'")
        else
            CONNECTED_PLAYERS=0
        fi
    else
        rm -f "$CIV_DATA_ROOT/ModUserData/PlayersConnected-1.db"
        CONNECTED_PLAYERS=0
    fi

    echo "Players connected: $CONNECTED_PLAYERS"
    aws cloudwatch put-metric-data --namespace /PitbossServer/ --metric-data "MetricName=ActiveConnections,Dimensions=[{Name=InstanceId,Value=$INSTANCE_ID}],Value=$CONNECTED_PLAYERS"
    sleep 60
done

