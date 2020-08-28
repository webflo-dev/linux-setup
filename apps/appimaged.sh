#!/bin/zsh

appimaged_info() {
    echo "https://github.com/AppImage/appimaged"
}

appimaged_install() {
    declare appImageName=appimaged-x86_64.AppImage

    download_file \
        "https://github.com/AppImage/appimaged/releases/download/continuous/$appImageName" \
        $appImageName

    chmod u+x $tempdir/$appImageName
    sh -c "$tempdir/$appImageName --install"
}
