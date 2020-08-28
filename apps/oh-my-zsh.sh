#!/bin/zsh

oh-my-zsh_info() {
    echo "https://ohmyz.sh"
}

oh-my-zsh_install() {
    declare tmp_file=oh-my-zsh_$(date +%s).sh

    download_file \
        "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" \
        $tmp_file

    ZSH=~/.oh-my-zsh RUNZSH=no KEEP_ZSHRC=yes CHSH=no sh $tempdir/$tmp_file

    declare zdir=${ZSH_CUSTOM:=~/.oh-my-zsh/custom}

    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $zdir/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions $zdir/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-completions $zdir/plugins/zsh-completions
    git clone https://github.com/supercrabtree/k $zdir/plugins/k

    git clone https://github.com/denysdovhan/spaceship-prompt.git "$zdir/themes/spaceship-prompt"
    ln -s "$zdir/themes/spaceship-prompt/spaceship.zsh-theme" "$zdir/themes/spaceship.zsh-theme"
}
