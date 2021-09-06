#!/bin/bash

CIV_DATA_ROOT="/root/My Games/Sid Meier's Civilization 5"

while : ; do

echo "Waiting for sqlite file update..."
inotifywait -e modify -q "$CIV_DATA_ROOT/ModUserData/TurnStatus-1.db"
while : ; do
    PLAYER_STR=$(sqlite3 "$CIV_DATA_ROOT/ModUserData/TurnStatus-1.db" "SELECT Value FROM SimpleValues WHERE Name = 'PlayersWhoNeedToTakeTheirTurn';")
    if [ $? -eq 0 ]; then
        break
    fi
done
while : ; do
    TURN_NUM=$(sqlite3 "$CIV_DATA_ROOT/ModUserData/TurnStatus-1.db" "SELECT Value FROM SimpleValues WHERE Name = 'TurnNum';")
    if [ $? -eq 0 ]; then
        break
    fi
done

PLAYERS=$(echo $PLAYER_STR | python3 -c "import sys; print('[' + ','.join([f'{{S=\'{name}\'}}' for name in sys.stdin.read().strip().split('\x1F')]) + ']', end='')")

echo "Turn #: $TURN_NUM"
echo "Player disconnected."
echo "The following players still need to take their turns:"
echo $PLAYERS

CURRENT_DATE=$(date --iso-8601=sec)

aws dynamodb put-item --table-name $TURN_STATUS_DYNAMODB_TABLE --item "turn_num={N=$TURN_NUM},timestamp={S=$CURRENT_DATE},users={L=$PLAYERS}"

done

