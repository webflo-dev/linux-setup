#!/bin/zsh

declare appImageName=appimaged-x86_64.AppImage

download_file \
    "https://github.com/AppImage/appimaged/releases/download/continuous/$appImageName" \
    $appImageName

chmod u+x $tempdir/$appImageName
sh -c "$tempdir/$appImageName --install"
