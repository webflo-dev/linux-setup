#!/bin/bash

declare tmp_file = 'jkjhkghrkghegkhj-omz.sh' 

wget -O $tmp_file  https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh;
ZSH=~/.oh-my-zsh RUNZSH=no KEEP_ZSHRC=yes CHSH=no sh install.sh;
rm $tmp_file;

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions

git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
