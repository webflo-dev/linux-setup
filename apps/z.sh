#!/bin/zsh

declare repo=rupa/z
declare version=$(get_latest_release_github $repo)
declare file=z-$version.tar.gz
declare tmp_dir=$tempdir/z

download_file \
    https://github.com/$repo/archive/$version.tar.gz \
    $file

mkdir -p \
    $tmp_dir \
    $homedir/.zsh

tar xvf $tempdir/$file -C $tmp_dir --strip-components=1
cp -f $tmp_dir/z.sh $homedir/.zsh/z.zsh
cp -f $tmp_dir/z.1 /usr/local/man/man1
