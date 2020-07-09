#!/bin/zsh

declare repo=dim-an/cod
declare version=$(get_latest_release_github $repo)
declare file=cod-Linux.tgz
declare tmp_dir=$tempdir/cod

download_file \
    https://github.com/$repo/releases/download/$version/$file \
    $file

mkdir -p \
    $tmp_dir \
    $homedir/.zsh

tar xvf $tempdir/$file -C $tmp_dir --strip-components=1
cp -f $tmp_dir/cod $bindir

$bindir/cod init $$ zsh >$homedir/.zsh/cod.zsh
