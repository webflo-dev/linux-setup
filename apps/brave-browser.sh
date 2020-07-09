#!/bin/zsh

install_apt \
    brave-browser \
    '' \
    https://brave-browser-apt-release.s3.brave.com/brave-core.asc \
    https://brave-browser-apt-release.s3.brave.com \
    stable \
    main
