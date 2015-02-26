#!/bin/bash

set -o nounset
set -o errexit

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"
NODE_VERSION=v0.12.0
NODE_ARCH_FILE=node-${NODE_VERSION}-linux-x64.tar.gz

###############################################################################
# Install node and related stuff
mkdir -p ~/tmp
cd ~/tmp
wget http://nodejs.org/dist/${NODE_VERSION}/${NODE_ARCH_FILE}
sudo tar xvf ~/tmp/${NODE_ARCH_FILE} -C /opt
rm -fv ~/tmp/${NODE_ARCH_FILE}
cd /opt
sudo ln -sn node-${NODE_VERSION}-linux-x64 node
sudo ln -sn /opt/node/bin/node /usr/local/bin/node
sudo ln -sn /opt/node/bin/npm /usr/local/bin/npm

###############################################################################

###############################################################################
# Install docker
[ -e /usr/lib/apt/methods/https ] || { sudo apt-get update && sudo apt-get install -y apt-transport-https; }
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
sudo sh -c \"echo deb https://get.docker.com/ubuntu docker main > /etc/apt/sources.list.d/docker.list\"
sudo apt-get update
sudo apt-get install -y lxc-docker-1.3.3

sudo usermod -aG docker ubuntu
###############################################################################

###############################################################################
# Install other needed packages
sudo apt-get install -y make
sudo apt-get install -y openjdk-7-jdk
sudo apt-get install -y jq
sudo apt-get install -y maven
###############################################################################

###############################################################################
# Install yo, bower, grunt with the right modules using the package.json in movie-demo-frontend project
mkdir -p ~/tmp
cd ~/tmp
git clone https://github.com/SeldonIO/movie-demo-frontend
cd movie-demo-frontend
echo "Installing yo, bower, grunt-cli"
sudo npm install -g yo bower grunt-cli
sudo chown -R ubuntu:ubuntu ~/.npm
rm -rf ~/tmp/movie-demo-frontend/
###############################################################################


