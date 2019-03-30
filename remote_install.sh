#!/usr/bin/env bash

USERNAME_AT_SERVER=$1
if [ -z "$USERNAME_AT_SERVER" ]; then
 echo "!!!Invalid input params"
 echo "Usage: bash remote_install.sh [username@server_ip]"
 echo "Example: bash remote_install.sh pi@192.168.1.10"
else
 if ! [ -x "$(command -v docker)" ]; then
  ssh $USERNAME_AT_SERVER "sudo curl -sSL https://get.docker.com | sh && sudo docker pull tlnguyen/freqtrade.pi && mkdir ~/freqtrade"
 fi
 scp -r ./freqtrade/* $USERNAME_AT_SERVER:~/freqtrade
fi