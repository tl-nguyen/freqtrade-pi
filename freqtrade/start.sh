#!/usr/bin/env bash

STRATEGY_CONTAINER_NAME=$1
STRATEGY_CLASS=$2
FREQTRADE_PARAMS=$3

if [ -z "$STRATEGY_CONTAINER_NAME" ] || [ -z "$STRATEGY_CLASS" ]; then
 echo "Usage: bash start.sh [strategy_container_name] [strategy_class] [freqtrade_params_optional]"
 echo 'Example: bash start.sh default_strategy DefaultStrategy "--dynamic-whitelist 100"'
else
 if sudo docker ps | grep -q $STRATEGY_CONTAINER_NAME; then
    sudo docker stop $STRATEGY_CONTAINER_NAME && sudo docker rm $STRATEGY_CONTAINER_NAME
 fi
 sudo docker run -d --restart always --name $STRATEGY_CONTAINER_NAME \
 -v /etc/localtime:/etc/localtime:ro \
 -v ~/freqtrade/strategies/$STRATEGY_CONTAINER_NAME.json:/freqtrade/config.json \
 -v ~/freqtrade/strategies/$STRATEGY_CONTAINER_NAME.sqlite:/freqtrade/tradesv3.sqlite \
 -v ~/freqtrade/strategies/:/freqtrade/user_data/strategies \
 tlnguyen/freqtrade.pi --db-url sqlite:///tradesv3.sqlite -c config.json --strategy $STRATEGY_CLASS $FREQTRADE_PARAMS
fi