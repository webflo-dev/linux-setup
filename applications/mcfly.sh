#!/bin/bash

declare repo=cantino/mcfly
declare version=$(get_latest_release_github $repo)
declare file=mcfly-$version-x86_64-unknown-linux-gnu.tar.gz
declare url=
declare tmp_dir=$tempdir/mcfly

download_file \
    https://github.com/$repo/releases/download/$version/$file \
    $file

mkdir -p \
    $tmp_dir \
    $homedir/.zsh

tar xvf $tempdir/$file -C $tmp_dir
cp $tmp_dir/mcfly $bindir
cp $tmp_dir/mcfly.zsh $homedir/.zsh/mcfly.zsh
