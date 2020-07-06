#!/bin/bash

declare repo=alexkim205/G-Desktop-Suite
declare version=$(get_latest_release_github $repo)
declare file=G-Desktop-Suite-"${version:1}".deb

download_file \
    https://github.com/$repo/releases/download/$version/$file \
    $file

aptx install $tempdir/$file
