#!/bin/bash

declare ini_file=$stepdir/apt-sources.ini;


step "Installing APT sources..."
while IFS="|" read -r app key url distrib component || [ -n "$app" ]
do
	[[ $app =~ ^#.* ]] && continue;
	curl -sSL $key | apt-key add -;
	echo "deb [arch=amd64] $url $distrib $component" | tee /etc/apt/sources.list.d/$app.list;
done < $ini_file;

aptx update;

