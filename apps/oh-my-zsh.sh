#!/bin/zsh

declare tmp_file=$tempdir/oh-my-zsh_$(date +%s).sh

wget -O $tmp_file https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
ZSH=~/.oh-my-zsh RUNZSH=no KEEP_ZSHRC=yes CHSH=no sh $tmp_file

declare zdir=${ZSH_CUSTOM:=~/.oh-my-zsh/custom}

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $zdir/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $zdir/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions $zdir/plugins/zsh-completions
git clone https://github.com/supercrabtree/k $zdir/plugins/k

git clone https://github.com/denysdovhan/spaceship-prompt.git "$zdir/themes/spaceship-prompt"
ln -s "$zdir/themes/spaceship-prompt/spaceship.zsh-theme" "$zdir/themes/spaceship.zsh-theme"
