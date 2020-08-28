#!/bin/zsh

vscode_install() {
    install_apt \
        vscode \
        '' \
        https://packages.microsoft.com/keys/microsoft.asc \
        https://packages.microsoft.com/repos/vscode \
        stable \
        main
}
