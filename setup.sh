#!/bin/bash

setup_color() {
	# Only use colors if connected to a terminal
	if [ -t 1 ]; then
		RED=$(printf '\033[31m')
		GREEN=$(printf '\033[32m')
		YELLOW=$(printf '\033[33m')
		BLUE=$(printf '\033[34m')
		BOLD=$(printf '\033[1m')
		RESET=$(printf '\033[m')
	else
		RED=""
		GREEN=""
		YELLOW=""
		BLUE=""
		BOLD=""
		RESET=""
	fi
}

error() {
	echo ${RED}"Error: $@"${RESET} >&2
}

step() {
    echo ${BLUE}"===== $@"${RESET}
}

__apt() {
    apt -y -qq $@
}

setup_color;



step "Updating system"
__apt update && __apt full-upgrade && __apt autoremove; 



step "Installing prerequisite"
__apt install \
    apt-transport-https \
    software-properties-common \
    curl \
    wget \
    ca-certificates \
    gnupg-agent \
	;



step "Installing PPA"
while IFS="" read -r ppa || [ -n "$ppa" ]
do
	[[ $ppa =~ ^#.* ]] && continue;
	add-apt-repository $ppa;
done < "./ppa.txt"



step "Installing APT sources..."
while IFS="|" read -r app key url distrib component || [ -n "$ppa" ]
do
	[[ $app =~ ^#.* ]] && continue;
	curl -sSL $key | apt-key add -;
	echo "deb [arch=amd64] $url $distrib $component" | tee /etc/apt/sources.list.d/$app.list;
done < "./apt-source.txt"



step "Installing applications using APT"
xargs -a <(awk '! /^ *(#|$)/' "./apps.txt") -r -- __apt install;



step "Installing applications using DEB"
while IFS="" read -r url || [ -n "$url" ]
do
	[[ $url =~ ^#.* ]] && continue;
	add-apt-repository $url;
done < "./deb.txt"



step "Installing custom applications"
for extra in ./setup-extra/*.sh; do
	echo ">> running $extra";
    source $extra;
done



step "Changing shell to ZSH"
chsh -s /bin/zsh && su - $USER;



step "Refreshing shell"
source ~/.zshrc;



step "DONE !"
