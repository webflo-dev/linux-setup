#!/bin/bash

step "Cleaning up temp files"
rm -rf $tempdir;

step "Changing shell to ZSH"
chsh -s /bin/zsh && su - $USER;

step "Refreshing shell"
source $homedir/.zshrc;

