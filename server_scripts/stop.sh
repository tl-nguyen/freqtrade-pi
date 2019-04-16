#!/usr/bin/env bash

STRATEGY_CONTAINER_NAME=$1

if [ -z "$STRATEGY_CONTAINER_NAME" ]; then
    echo "Usage: bash stop.sh [strategy_container_name]"
    echo "Example: bash stop.sh default_strategy"
elif sudo docker ps | grep -q $STRATEGY_CONTAINER_NAME; then
    echo "Stopping $STRATEGY_CONTAINER_NAME strategy ..."
    sudo docker stop $STRATEGY_CONTAINER_NAME && sudo docker rm $STRATEGY_CONTAINER_NAME

    echo "Do you want to remove $STRATEGY_CONTAINER_NAME.sqlite db file? [y/N]"
    read answer
    if [ "$answer" == "y" ] && [ -f ~/freqtrade/strategies/$STRATEGY_CONTAINER_NAME.sqlite ]; then
        echo "Removing $STRATEGY_CONTAINER_NAME.sqlite ..."
        rm -f ~/freqtrade/strategies/$STRATEGY_CONTAINER_NAME.sqlite
    fi
fi