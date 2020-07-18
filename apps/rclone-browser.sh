#!/bin/zsh

declare asset_name=$(curl -ssL https://api.github.com/repos/kapitainsky/RcloneBrowser/releases/latest |
    grep "name.*linux-x86_64\.AppImage" |
    cut -d '"' -f 4)

declare target=$bindir/$asset_name

url=$(curl -s https://api.github.com/repos/kapitainsky/RcloneBrowser/releases/latest |
    grep "browser_download_url.*linux-x86_64" |
    cut -d '"' -f 4)

download_file $url $asset_name
mv $tempdir/$asset_name $target
chmod +x $target
