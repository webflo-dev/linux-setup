#!/bin/zsh

backintime_info() {
    echo "https://github.com/bit-team/backintime"
}

backintime_install() {

    install_apt \
        backintime-qt4 \
        ppa:bit-team/stable
}
