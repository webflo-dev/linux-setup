#!/bin/bash

add_apt_key "docker" \
    "https://download.docker.com/linux/ubuntu/gpg" \
    "https://download.docker.com/linux/ubuntu" \
    "focal" \
    "stable";

aptx update;
aptx install docker-ce docker-ce-cli containerd.io;

groupadd docker;
usermod -aG docker $USER;
systemctl enable docker;
