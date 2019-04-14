#!/usr/bin/env bash

## Usage: ./fp.sh [commands] [options] arg1
## 
## Commands:
##
##  help        Displays this message
##
##  install     Install docker (if not installed) and move server scripts into RPI
##              OPTIONS: --username, --hostname
##
##  update      Update/Move a strategy into RPI
##              OPTIONS: --username, --hostname, --strategy-file-name
##
##  start       Start a strategy
##              OPTIONS: --username, --hostname, --strategy-file-name
##
##  stop        Stop a strategy
##              OPTIONS: --username, --hostname, --strategy-file-name
##
##  logs        Show and follow the logs for a specific strategy
##              OPTIONS: --username, --hostname, --strategy-file-name
##
##  ps          Show how many strategies are running and some meta data about them
##              OPTIONS: --username, --hostname
##
##
## Options:
##
##  -u, --username              Username that you login to your RPI (default is pi).
##                              NOTE: username is optional if specified in the config.yml file
##
##  -h, --hostname              Hostname or IP Address of your RPI.  
##                              NOTE: hostname is optional if specified in the config.yml file
##
##  -s, --strategy-file-name    The strategy file name for your .py and .json files
##                              EXAMPLE: you have bbrsi.py and bbrsi.json
##                              USAGE: -s bbrsi
##                              IMPORTANT: You have to specify the strategy file name and the associated class name in the config.yml file
##
##  -p, --freqtrade-params      Params from freqtrade
##                              EXAMPLE: You want to use dynamic white list param
##                              USAGE: -p '--dynamic-whitelist 50' 

COMMAND=$1

# Populate defaults
parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

eval $(parse_yaml config.yml)
USERNAME=$username
HOSTNAME=$hostname

# Populate flags
while :; do
    case $2 in
        -u|--username) USERNAME=$3; shift; shift;;      
        -h|--hostname) HOSTNAME=$3; shift; shift;;
        -s|--strategy-file-name) STRATEGY_FILE_NAME=$3; shift; shift;;
        -p|--freqtrade-params) FREQTRADE_PARAMS=$3; shift; shift;;
        *) break
    esac
done

# Remote Commands
remote_install() {
    USERNAME_AT_SERVER=$1

    if [ -z "$USERNAME_AT_SERVER" ]; then
        echo "Error: You have to specify --username and --hostname options"
        echo "Usage: ./fp.sh install -u [username] -h [hostname]"
    else
        echo "Checking if docker is installed ..."
        DOCKER_CHECK=$(ssh $USERNAME_AT_SERVER "command -v docker")
        if [ -z "$DOCKER_CHECK" ]; then
            echo "No Docker in this machine, start installing docker ..."
            ssh $USERNAME_AT_SERVER "sudo curl -sSL https://get.docker.com | sh && sudo docker pull tlnguyen/freqtrade.pi && mkdir ~/freqtrade"
        fi
        echo "Updating server scripts ..."
        sed -i 's/\r$//' ./freqtrade/start.sh && sed -i 's/\r$//' ./freqtrade/stop.sh
        scp ./freqtrade/start.sh ./freqtrade/stop.sh $USERNAME_AT_SERVER:~/freqtrade
    fi
}

remote_start() {
    USERNAME_AT_SERVER=$1
    STRATEGY_CONTAINER_NAME=$2
    FREQTRADE_PARAMS=$3
    TEMP="strategies_$2" && STRATEGY_CLASS=${!TEMP}

    if [ -z "$USERNAME_AT_SERVER" ] || [ -z "$STRATEGY_CONTAINER_NAME" ] || [ -z "$STRATEGY_CLASS" ]; then
        echo "Error: You have to specify --username, --hostname and --strategy-file-name --strategy-class-name options"
        echo "Usage: ./fp.sh update -u [username] -h [hostname] -s [strategy_file_name] -c [strategy_class_name] -p '(freqtrade_params)'"        
    else
        ssh $USERNAME_AT_SERVER "bash ~/freqtrade/start.sh $STRATEGY_CONTAINER_NAME $STRATEGY_CLASS '$FREQTRADE_PARAMS'"
    fi
}

remote_stop() {
    USERNAME_AT_SERVER=$1
    STRATEGY_CONTAINER_NAME=$2

    if [ -z "$USERNAME_AT_SERVER" ] || [ -z "$STRATEGY_CONTAINER_NAME" ]; then
        echo "Error: You have to specify --username, --hostname and --strategy-file-name options"
        echo "Usage: ./fp.sh update -u [username] -h [hostname] -s [strategy_file_name]"        
    else
        ssh $USERNAME_AT_SERVER "bash ~/freqtrade/stop.sh $STRATEGY_CONTAINER_NAME"
    fi  
}

remote_update() {
    USERNAME_AT_SERVER=$1
    STRATEGY_CONTAINER_NAME=$2

    if [ -z "$USERNAME_AT_SERVER" ] || [ -z "$STRATEGY_CONTAINER_NAME" ]; then
        echo "Error: You have to specify --username, --hostname and --strategy-file-name options"
        echo "Usage: ./fp.sh update -u [username] -h [hostname] -s [strategy_file_name]"    
    else
        echo "Copying $STRATEGY_CONTAINER_NAME.py and $STRATEGY_CONTAINER_NAME.json to server ..."
        scp ./freqtrade/strategies/$STRATEGY_CONTAINER_NAME.py ./freqtrade/strategies/$STRATEGY_CONTAINER_NAME.json $USERNAME_AT_SERVER:~/freqtrade/strategies 

        echo "Checking if the strategy is running ..."
        STRATEGY_IS_RUNNING=$(ssh $USERNAME_AT_SERVER "sudo docker ps | grep $STRATEGY_CONTAINER_NAME")
        if [ ! -z "$STRATEGY_IS_RUNNING" ]; then
            echo "Restart $STRATEGY_CONTAINER_NAME ..."
            ssh $USERNAME_AT_SERVER "sudo docker restart $STRATEGY_CONTAINER_NAME"
        fi
    fi
}

remote_logs() {
    USERNAME_AT_SERVER=$1
    STRATEGY_CONTAINER_NAME=$2

    if [ -z "$USERNAME_AT_SERVER" ] || [ -z "$STRATEGY_CONTAINER_NAME" ]; then
        echo "Error: You have to specify --username, --hostname and --strategy-file-name options"
        echo "Usage: ./fp.sh logs -u [username] -h [hostname] -s [strategy_file_name]"        
    else 
        ssh $USERNAME_AT_SERVER "sudo docker logs -f $STRATEGY_CONTAINER_NAME"
    fi
}

remote_ps() {
    USERNAME_AT_SERVER=$1

    if [ -z "$USERNAME_AT_SERVER" ]; then
        echo "Error: You have to specify --username, --hostname options"
        echo "Usage: ./fp.sh ps -u [username] -h [hostname]"        
    else 
        ssh $USERNAME_AT_SERVER "sudo docker ps"
    fi
}

help() {
  [ "$*" ] && echo "$0: $*"
  sed -n '/^##/,/^$/s/^## \{0,1\}//p' "$0"
  exit 2
} 2>/dev/null

case $COMMAND in
    init) echo "init";;
    install) remote_install $USERNAME@$HOSTNAME;;
    update) remote_update $USERNAME@$HOSTNAME $STRATEGY_FILE_NAME;;
    start) remote_start $USERNAME@$HOSTNAME $STRATEGY_FILE_NAME "$FREQTRADE_PARAMS";;
    stop) remote_stop $USERNAME@$HOSTNAME $STRATEGY_FILE_NAME;;
    logs) remote_logs $USERNAME@$HOSTNAME $STRATEGY_FILE_NAME;;
    ps) remote_ps $USERNAME@$HOSTNAME;;
    help) help;;
    *) echo "Try './fp.sh help' for some more instructions"
esac