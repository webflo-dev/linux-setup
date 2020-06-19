#!/bin/bash

declare asset_name=$(curl -ssL https://api.github.com/repos/kapitainsky/RcloneBrowser/releases/latest \
    | grep "name.*linux-x86_64\.AppImage" \
    | cut -d '"' -f 4);

if [ -d $asset_name]; then
    error "⚠ Rclone-browser cannot be downloaded..."
    exit -1;
fi

declare target=$bindir/$asset_name;

curl -s https://api.github.com/repos/kapitainsky/RcloneBrowser/releases/latest \
| grep "browser_download_url.*linux-x86_64" \
| cut -d '"' -f 4 \
| wget -O $target -i -;

chmod +x $target;