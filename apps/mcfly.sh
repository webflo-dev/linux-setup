#!/bin/zsh

mcfly_info() {
    echo "https://github.com/cantino/mcfly"
}

mcfly_install() {
    declare repo=cantino/mcfly
    declare version=$(get_latest_release_github $repo)
    declare file=mcfly-$version-x86_64-unknown-linux-gnu.tar.gz
    declare tmp_dir=$tempdir/mcfly

    download_file \
        https://github.com/$repo/releases/download/$version/$file \
        $file

    mkdir -p \
        $tmp_dir \
        $zshdir

    tar xvf $tempdir/$file -C $tmp_dir
    cp -f $tmp_dir/mcfly $bindir
    cp -f $tmp_dir/mcfly.zsh $zshdir/mcfly.zsh
}
