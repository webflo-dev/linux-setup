#!/bin/bash

declare tmp_file=G-Desktop-Suite.deb;

curl -s https://api.github.com/repos/alexkim205/G-Desktop-Suite/releases/latest \
| grep "browser_download_url.*deb" \
| cut -d '"' -f 4 \
| wget -O $tmp_file -i - 

apt -y -qq install ./$tmp_file;
rm ./$tmp_file;