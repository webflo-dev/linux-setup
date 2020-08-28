#!/bin/zsh

onlyoffice_info() {
    echo "https://www.onlyoffice.com/fr"
}

onlyoffice_install() {
    install_deb \
        onlyoffice \
        https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb
}
