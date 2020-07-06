#!/bin/bash

declare appImageName=appimaged-x86_64.AppImage
declare target=$tempdir/$appImageName

wget -O $target "https://github.com/AppImage/appimaged/releases/download/continuous/$appImageName"
chmod a+x $target
sh -c "$target --install"
