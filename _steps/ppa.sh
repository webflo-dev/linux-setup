#!/bin/bash

declare ini_file=$stepdir/ppa.ini;

step "Installing PPA"
while IFS="" read -r ppa || [ -n "$ppa" ]
do
	[[ $ppa =~ ^#.* ]] && continue;
	add-apt-repository $ppa;
done < $ini_file;
