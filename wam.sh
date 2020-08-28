#!/bin/zsh

declare app_version=1.0.0

autoload -Uz colors
colors

declare cmd="wam"
declare app_title="Webflo Applications Manager"
# declare WAM_DIR=${WEBFLO_DIR:-$HOME/.webflo}/wam
declare WAM_DIR=$(pwd)
declare appsdir=${WAM_DIR}/apps

source $WAM_DIR/src/helper.sh
source $WAM_DIR/src/spin.sh

_usage() {
    cat <<EOF
$app_title (v${app_version})

Usage: $cmd [options] <commands> [<args>]
    $cmd install [--all] <applications>...

Commands:
    install         install one or more applications

Options:
    -h, --help      Show this help message
    -v, --version   Show script version

EOF
}


prerequisites() {
    #aptx install curl git
}

cleanup() {
    rm -rf $tempdir $logfile $spinnerfile
}

traperr() {
    tput cnorm
}


_wam() {
    local help version ctx

    zparseopts -E  \
        h=help -help=help \
        v=version -version=version

    if [[ -n $help ]]; then
        _usage
        exit 0
    fi

    if [[ -n $version ]]; then
        echo $app_version
        exit 0
    fi

    ctx="$1"
    command=$WAM_DIR/src/commands/$ctx.sh

    if [[ ! -f $command ]]; then
        echo "Command $fg[red]$ctx$reset_color is not recognised"
        exit 1
    fi

    source $command
    _$ctx "${(@)@:2}"

    # case $ctx in
    # install)
    #     _wam_$ctx "${(@)@:2}"
    #     ;;
    # *)
    #     echo "Command $fg[red]$ctx$reset_color is not recognised"
    #     exit 1
    #     ;;
    # esac
}

trap traperr ERR
_wam "$@"
