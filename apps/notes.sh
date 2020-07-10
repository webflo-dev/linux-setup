#!/bin/zsh

install_script \
    "notes" \
    "https://raw.githubusercontent.com/pimterry/notes/latest-release/install.sh"

download_file \
    "https://raw.githubusercontent.com/pimterry/notes/latest-release/_notes" \
    /usr/local/share/zsh/site-functions/_notes \
    "no-temp"
