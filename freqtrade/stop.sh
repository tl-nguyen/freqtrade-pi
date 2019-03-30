#!/usr/bin/env bash

STRATEGY_CONTAINER_NAME=$1

if [ -z "$STRATEGY_CONTAINER_NAME" ]; then
 echo "Usage: bash stop.sh [strategy_container_name]"
 echo "Example: bash stop.sh default_strategy"
elif sudo docker ps | grep -q $STRATEGY_CONTAINER_NAME; then
 sudo docker stop $STRATEGY_CONTAINER_NAME && sudo docker rm $STRATEGY_CONTAINER_NAME
fi