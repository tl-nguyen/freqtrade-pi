#!/usr/bin/env bash

USERNAME_AT_SERVER=$1
STRATEGY_CONTAINER_NAME=$2
STRATEGY_CLASS=$3
FREQTRADE_PARAMS=$4

if [ -z "$USERNAME_AT_SERVER" ] || [ -z "$STRATEGY_CONTAINER_NAME" ] || [ -z "$STRATEGY_CLASS" ] ; then
 echo "Usage: bash remote_start.sh [username@server_ip] [strategy_container_name] [strategy_class] '[freqtrade_params_optional]'"
 echo 'Example: bash remote_start.sh pi@192.168.1.10 default_strategy DefaultStrategy "--dynamic-whitelist 100"'
else
 ssh $USERNAME_AT_SERVER "bash ~/freqtrade/start.sh $STRATEGY_CONTAINER_NAME $STRATEGY_CLASS '$FREQTRADE_PARAMS'"
fi