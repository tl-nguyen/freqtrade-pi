#!/usr/bin/env bash

STRATEGY_CONTAINER_NAME=$1
DESTROY_DB=$2

if [ -z "$STRATEGY_CONTAINER_NAME" ]; then
 echo "Usage: bash stop.sh [strategy_container_name] (destroy_db_optional)"
 echo "Example: bash stop.sh default_strategy"
elif sudo docker ps | grep -q $STRATEGY_CONTAINER_NAME; then
 echo "Stopping $STRATEGY_CONTAINER_NAME strategy ..."
 sudo docker stop $STRATEGY_CONTAINER_NAME && sudo docker rm $STRATEGY_CONTAINER_NAME

 if [ -z "$DESTROY_DB" ]; then
  echo "Removing db $STRATEGY_CONTAINER_NAME.sqlite ..."
  rm -f ~/freqtrade/strategies/$STRATEGY_CONTAINER_NAME.sqlite
 fi
fi