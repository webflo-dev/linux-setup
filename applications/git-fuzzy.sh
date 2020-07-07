#!/bin/bash

declare target=$bindir/git-fuzzy-repo

git clone https://github.com/bigH/git-fuzzy.git $target
ln -s $target/bin/git-fuzzy $bindir/git-fuzzy
