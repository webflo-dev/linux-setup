#!/bin/zsh

aptx remove \
    docker \
    docker-engine \
    docker.io \
    containerd runc

aptx install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

add_apt_key "docker" \
    "https://download.docker.com/linux/ubuntu/gpg" \
    "https://download.docker.com/linux/ubuntu" \
    $(lsb_release -cs) \
    "stable"

apt-key fingerprint 0EBFCD88

aptx update
aptx install docker-ce docker-ce-cli containerd.io

groupadd docker
usermod -aG docker $USER
systemctl enable docker
