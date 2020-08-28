#!/bin/zsh

emojify_info() {
    echo "https://github.com/mrowa44/emojify"
}

emojify_install() {

    download_file \
        "https://raw.githubusercontent.com/mrowa44/emojify/master/emojify" \
        $bindir/emojify \
        "no-temp"

    chmod u+x $bindir/emojify
}
