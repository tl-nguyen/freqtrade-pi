#!/usr/bin/env bash

USERNAME_AT_SERVER=$1
if [ -z "$USERNAME_AT_SERVER" ]; then
 echo "!!!Invalid input params"
 echo "Usage: bash remote_install.sh [username@server_ip]"
 echo "Example: bash remote_install.sh pi@192.168.1.10"
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