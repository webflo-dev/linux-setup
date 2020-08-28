#!/bin/zsh

discord_info() {
    echo "https://discord.com"
}

discord_install() {
    install_deb \
        discord \
        "https://discord.com/api/download?platform=linux&format=deb"
}
