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
    aptx install curl git
}

cleanup() {
    rm -rf $tempdir $logfile $spinnerfile
}

traperr() {
    tput cnorm
}

_info() {
    local apps=("${(@)@}")

    if [[ ${#apps[@]} -eq 0 ]]; then
        echo "Specify 1 or more application(s)"
        exit 0
    fi

    for app in $apps; do
        source $appsdir/$app.sh
        "${app}_info"
    done
}

_install(){
    local all_apps appfile ctx="$1"
    local -a apps

    zparseopts -D -E -- -all=all_apps

    if [[ -n $all_apps ]]; then
        apps=("${(@f)$(ls $appsdir/*.sh)}")
    else
        ctx=("${(@)@}")
        for app in $ctx; do
            appfile=$appsdir/$app.sh
            if [[ ! -f $appfile ]]; then
                cat <<EOF
Application $fg[red]$app$reset_color not found
EOF
                exit 1
            fi
            apps+=($appfile)
        done
    fi

    if [[ ${#apps[@]} -eq 0 ]]; then
        echo "Specify 1 or more application(s) to install"
        exit 0;
    fi

    declare bindir=$HOME/bin
    declare zshdir=$HOME/.zsh
    declare tempdir=/tmp/wam-files-$(date +%s)
    declare spinnerfile=/tmp/wam-spinner-$(date +%s).log
    declare logfile=/tmp/wam-$(date +%s).log

    mkdir -p $tempdir $bindir $zshdir

    cat <<EOF
    
    $fg[cyan]$cmd$reset_color ($app_title) 

EOF

    execute \
        --title "Installing prerequisites" \
        "prerequisites"

    local name;
    for app in $apps; do
        name=$(basename ${app%.*})
        source $app
        execute --title "$name" "${name}_install"
    done
    unset name;

    execute \
        --title "Cleaning-up" \
        "cleanup"

    cat <<EOF

    $fg[yellow]Done !$reset_color 

EOF
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

    case "$ctx" in
    install | info)
        _$ctx "${(@)@:2}"
        ;;
    *)
        echo "Command $fg[red]$ctx$reset_color is not recognised"
        exit 1
    ;;
    esac
}

trap traperr ERR
_wam "$@"
