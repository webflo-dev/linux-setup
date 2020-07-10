#!/bin/zsh

download_file \
    "https://raw.githubusercontent.com/mrowa44/emojify/master/emojify" \
    $bindir/emojify \
    "no-temp"

chmod u+x $bindir/emojify
