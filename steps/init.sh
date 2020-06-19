#!/bin/bash

aptx() {
    apt -y -qq $@
}

step "Updating system"
aptx update && aptx full-upgrade && aptx autoremove; 

step "Installing prerequisite"
aptx install \
    apt-transport-https \
    software-properties-common \
    curl \
    wget \
    ca-certificates \
    gnupg-agent \
	;
