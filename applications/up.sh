#!/bin/zsh

declare updir=$homedir/.zsh
mkdir -p $updir

curl https://raw.githubusercontent.com/shannonmoeller/up/master/up.sh \
    -o $updir/up.sh
