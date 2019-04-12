#!/usr/bin/env bash

STRATEGY_CONTAINER_NAME=$1
STRATEGY_CLASS=$2
FREQTRADE_PARAMS=$3

if [ -z "$STRATEGY_CONTAINER_NAME" ] || [ -z "$STRATEGY_CLASS" ]; then
 echo "Usage: bash start.sh [strategy_container_name] [strategy_class] [freqtrade_params_optional]"
 echo 'Example: bash start.sh default_strategy DefaultStrategy "--dynamic-whitelist 100"'
else
 if sudo docker ps | grep -q $STRATEGY_CONTAINER_NAME; then
   echo "Stopping the running strategy with the same name $STRATEGY_CONTAINER_NAME ..."
   sudo docker stop $STRATEGY_CONTAINER_NAME && sudo docker rm $STRATEGY_CONTAINER_NAME
 fi

 if [ ! -f ~/freqtrade/strategies/$STRATEGY_CONTAINER_NAME.sqlite ]; then
   echo "No db exists. Creating $STRATEGY_CONTAINER_NAME.sqlite ..."
   touch ~/freqtrade/strategies/$STRATEGY_CONTAINER_NAME.sqlite
 fi

 sudo docker run -d --restart always --name $STRATEGY_CONTAINER_NAME \
 -v /etc/localtime:/etc/localtime:ro \
 -v ~/freqtrade/strategies/$STRATEGY_CONTAINER_NAME.json:/freqtrade/config.json \
 -v ~/freqtrade/strategies/$STRATEGY_CONTAINER_NAME.sqlite:/freqtrade/$STRATEGY_CONTAINER_NAME.sqlite \
 -v ~/freqtrade/strategies/:/freqtrade/user_data/strategies \
 tlnguyen/freqtrade.pi --db-url sqlite:///$STRATEGY_CONTAINER_NAME.sqlite -c config.json --strategy $STRATEGY_CLASS $FREQTRADE_PARAMS
fi