#!/usr/bin/env bash

USERNAME_AT_SERVER=$1
STRATEGY_CONTAINER_NAME=$2

if [ -z "$USERNAME_AT_SERVER" ] || [ -z "$STRATEGY_CONTAINER_NAME" ]; then
 echo "Usage: bash remote_logs.sh [username@server_ip] [strategy_container_name]"
 echo "Example: bash remote_logs.sh pi@192.168.1.10 default_strategy"
else 
 ssh $USERNAME_AT_SERVER "sudo docker logs -f $STRATEGY_CONTAINER_NAME"
fi