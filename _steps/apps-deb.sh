#!/bin/bash

declare ini_file=$stepdir/deb.ini;

step "Installing applications using DEB"
while IFS="" read -r url || [ -n "$url" ]
do
	[[ $url =~ ^#.* ]] && continue;
	add-apt-repository $url;
done < $ini_file;
