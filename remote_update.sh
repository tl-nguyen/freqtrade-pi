#!/usr/bin/env bash

USERNAME_AT_SERVER=$1
STRATEGY_CONTAINER_NAME=$2

if [ -z "$USERNAME_AT_SERVER" ]; then
 echo "Usage: bash remote_update.sh [username@server_ip] [strategy_container_name_optional]"
 echo "Example: bash remote_update.sh pi@192.168.1.10 default_strategy"
 echo "!!!If strategy container name is missing, the script will update all of the strategies"
else
 echo "Copying db $STRATEGY_CONTAINER_NAME.py and $STRATEGY_CONTAINER_NAME.json to server ..."
 scp ./freqtrade/strategies/$STRATEGY_CONTAINER_NAME.py ./freqtrade/strategies/$STRATEGY_CONTAINER_NAME.json $USERNAME_AT_SERVER:~/freqtrade/strategies 

 echo "Checking if the strategy is running ..."
 STRATEGY_IS_RUNNING=$(ssh $USERNAME_AT_SERVER "sudo docker ps | grep -q $STRATEGY_CONTAINER_NAME")
 if [ -z "$STRATEGY_IS_RUNNING" ]; then
  echo "Restart $STRATEGY_CONTAINER_NAME ..."
  ssh $USERNAME_AT_SERVER "sudo docker restart $STRATEGY_CONTAINER_NAME"
 fi
fi