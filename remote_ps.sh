#!/usr/bin/env bash

USERNAME_AT_SERVER=$1

if [ -z "$USERNAME_AT_SERVER" ]; then
 echo "Usage: bash remote_ps.sh [username@server_ip]"
 echo "Example: bash remote_ps.sh pi@192.168.1.10"
else 
 ssh $USERNAME_AT_SERVER "sudo docker ps"
fi