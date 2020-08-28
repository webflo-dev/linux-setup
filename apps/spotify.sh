#!/bin/zsh

spotify_install() {
    install_apt \
        spotify \
        '' \
        https://download.spotify.com/debian/pubkey.gpg \
        http://repository.spotify.com \
        stable \
        non-free
}
