#!/bin/bash

declare tmp_file=icaclient_amd64.deb

declare url=https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html;
curl -sSL $url \
    | grep -Eo 'rel="[^\"]+"' \
    | awk -F\" '{print $2}'  \
    | awk '/icaclient_.*_amd64.deb/{print "http:"$0}' \
    | wget -O $tmp_file -i - 

apt -y -qq install ./$tmp_file;
rm ./$tmp_file;