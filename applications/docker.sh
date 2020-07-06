#!/bin/bash

add_apt_key "docker" \
    "https://download.docker.com/linux/ubuntu/gpg" \
    "https://download.docker.com/linux/ubuntu" \
    $(lsb_release -cs) \
    "stable"

apt-key fingerprint 0EBFCD88

aptx update
aptx remove docker docker-engine docker.io
aptx install docker-ce docker-ce-cli containerd.io

groupadd docker
usermod -aG docker $USER
systemctl enable docker
