#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
export LINUX_IMAGE_EXTRA_PACKAGE=linux-image-extra-$(uname -r)

sudo locale-gen en_GB.UTF-8

###############################################################################
# Ensure docker will use aufs
sudo apt-get update
sudo apt-get install -y -q $LINUX_IMAGE_EXTRA_PACKAGE
###############################################################################

###############################################################################
# install docker
[ -e /usr/lib/apt/methods/https ] || {
  apt-get update -y
  apt-get install -y apt-transport-https
}
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
sudo sh -c "echo deb https://get.docker.com/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
sudo apt-get update
sudo apt-get install -y lxc-docker.1.6.0

sudo usermod -aG docker vagrant
###############################################################################

###############################################################################
# install vim
sudo apt-get install -y vim
###############################################################################

