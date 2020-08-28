#!/bin/zsh

forgit_info() {
    echo "https://github.com/wfxr/forgit"
}

forgit_install() {
    download_file \
        "https://raw.githubusercontent.com/wfxr/forgit/master/forgit.plugin.zsh" \
        $zshdir/forgit.plugin.zsh \
        "no-temp"
}
