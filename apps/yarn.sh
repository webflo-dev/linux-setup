#!/bin/zsh

yarn_install() {
    install_apt \
        yarn \
        '' \
        https://dl.yarnpkg.com/debian/pubkey.gpg \
        https://dl.yarnpkg.com/debian \
        stable \
        main
}
