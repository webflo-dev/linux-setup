#!/bin/zsh

declare hdir=${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/h

unalias h

# dependencies
aptx install ack-grep

git clone https://github.com/paoloantinori/hhighlighter.git $hdir
mv $hdir/h.sh $hdir/h.plugin.zsh
