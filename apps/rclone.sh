#!/bin/zsh

rclone_info() {
    echo "https://rclone.org"
}

rclone_install() {
    install_deb \
        rclone \
        https://downloads.rclone.org/rclone-current-linux-amd64.deb
}
