#!/bin/zsh

aptx() {
    apt -y -qq $@
}

add_apt_key() {
    curl -sSL $2 | apt-key add -
    echo "deb [arch=amd64] $3 $4 $5" | tee /etc/apt/sources.list.d/$1.list
}

add_apt_repository() {
    add-apt-repository $1
}

download_file() {
    if [[ $3 == "no-temp" ]]; then
        curl -sSL $1 -o $2
    else
        curl -sSL $1 -o $tempdir/$2
    fi
}

install_deb() {
    local app=$1
    local url=$2
    if [ -z $url ]; then
        echo "url is missing"
    else
        file="$app.deb"
        download_file $url $file
        aptx install $tempdir/$file
        rm $tempdir/$file
    fi
}

install_apt() {
    local app=$1
    local ppa=$2
    local key=$3
    local url=$4
    local distrib=$5
    local component=$6
    if [ ! -z $ppa ]; then
        add_apt_repository $ppa
        aptx update
    elif [ ! -z $key ]; then
        add_apt_key $app $key $url $distrib $component
        aptx update
    fi
    aptx install $app
}

install_script() {
    local app=$1
    local url=$2
    local file=$app-$(date +%s).sh
    download_file $url $file
    zsh $tempdir/$file
}

get_latest_release_github() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" |
        grep '"tag_name":' |
        sed -E 's/.*"([^"]+)".*/\1/'
}
