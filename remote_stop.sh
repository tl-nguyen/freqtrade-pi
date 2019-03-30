#!/usr/bin/env bash

USERNAME_AT_SERVER=$1
STRATEGY_CONTAINER_NAME=$2

if [ -z "$USERNAME_AT_SERVER" ] || [ -z "$STRATEGY_CONTAINER_NAME" ]; then
 echo "Usage: bash remote_stop.sh [username@server_ip] [strategy_container_name]"
 echo "Example: bash remote_stop.sh pi@192.168.1.10 default_strategy"
else
 ssh $USERNAME_AT_SERVER "bash ~/freqtrade/stop.sh $STRATEGY_CONTAINER_NAME"
fi