#!/bin/zsh

aptx install kleopatra

declare gpg=$homedir/florent.gpg

if [ -d $gpg ]; then
    kleopatra -i $gpg
fi
