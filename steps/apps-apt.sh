#!/bin/bash

declare ini_file=$stepdir/apps-apt.ini;

step "Installing applications using APT"

apps=()
while IFS="" read -r app || [ -n "$app" ]
do
	[[ $app =~ ^#.* ]] && continue;
    apps+=($app);
done < $ini_file;

aptx install ${apps[@]};
