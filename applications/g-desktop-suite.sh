#!/bin/bash

declare tmp_file=$tempdir/G-Desktop-Suite.deb;

declare url=$(curl -s https://api.github.com/repos/alexkim205/G-Desktop-Suite/releases/latest \
| grep "browser_download_url.*deb" \
| cut -d '"' -f 4); 

download_file $url $tmp_file
aptx install $tmp_file;
rm $tmp_file;