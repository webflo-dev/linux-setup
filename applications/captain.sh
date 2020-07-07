#!/bin/zsh

echo "$CYAN Hello captain !$RESET"
cp $appsdir/captain.source.txt $bindir/captain.sh
ln -s $bindir/captain.sh $bindir/captain
echo "$CYAN Bye captain !$RESET"
