#!/usr/bin/env bash

USERNAME_AT_SERVER=$1
STRATEGY_CONTAINER_NAME=$2

if [ -z "$USERNAME_AT_SERVER" ]; then
 echo "Usage: bash remote_update.sh [username@server_ip] [strategy_container_name_optional]"
 echo "Example: bash remote_update.sh pi@192.168.1.10 default_strategy"
 echo "!!!If strategy container name is missing, the script will update all of the strategies"
elif [ -z "$STRATEGY_CONTAINER_NAME" ]; then
 scp -r ./freqtrade/strategies/* $USERNAME_AT_SERVER:~/freqtrade/strategies
else
 scp ./freqtrade/strategies/$STRATEGY_CONTAINER_NAME.* $USERNAME_AT_SERVER:~/freqtrade/strategies 
fi