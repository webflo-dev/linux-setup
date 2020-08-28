#!/bin/zsh

papirus-icon-theme_info() {
    echo "https://github.com/PapirusDevelopmentTeam/papirus-icon-theme"
}

papirus-icon-theme_install() {
    install_apt \
        papirus-icon-theme \
        ppa:papirus/papirus
}
