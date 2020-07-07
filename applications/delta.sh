#!/bin/zsh

declare repo=dandavison/delta
declare version=$(get_latest_release_github $repo)
declare file="git-delta_"$version"_amd64.deb"

download_file \
    https://github.com/$repo/releases/download/$version/$file \
    $file

aptx install $tempdir/$file

cat $appsdir/delta.config.txt >>$homedir/.gitconfig
