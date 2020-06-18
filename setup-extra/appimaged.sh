#!/bin/bash

declare appImageName=appimaged-x86_64.AppImage

wget "https://github.com/AppImage/appimaged/releases/download/continuous/$appImageName";
chmod a+x $appImageName;
sh -c "./$appImageName --install";
rm $appImageName;