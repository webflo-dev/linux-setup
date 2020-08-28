#!/bin/zsh

espanso_info() {
    echo "https://espanso.org"
}

espanso_install() {
    install_deb \
        "espanso" \
        https://github.com/federico-terzi/espanso/releases/latest/download/espanso-debian-amd64.deb
}
