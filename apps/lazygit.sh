#!/bin/zsh

lazygit_info() {
    echo "https://github.com/jesseduffield/lazygit"
}

lazygit_install() {
    install_apt \
        lazygit \
        ppa:lazygit-team/release
}
