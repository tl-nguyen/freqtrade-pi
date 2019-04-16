#!/usr/bin/env bash

echo "Checking if docker is installed ..."
if [ -z "$(command -v docker)" ]; then
    echo "No Docker in this machine, start installing docker ..."
    sudo curl -sSL https://get.docker.com | sh && sudo docker pull tlnguyen/freqtrade.pi
    echo "Docker installation finished."
else
    echo "Docker already exists, no installation needed"
fi
        
if [ ! -d ~/freqtrade/strategies ]; then
    echo "Creating project structure ..."
    mkdir -p ~/freqtrade/strategies
else
    echo "Do you want to remove the the strategies directory and start fresh? [y/N]"
    read answer
    if [ "$answer" == "y" ]; then
        sudo rm -rf ~/freqtrade/strategies
        mkdir -p ~/freqtrade/strategies
    fi
    echo "Project created."
fi

mv ~/start.sh ~/stop.sh ~/freqtrade
rm -f ~/install.sh
sudo chown -R $USER:$USER ~/freqtrade