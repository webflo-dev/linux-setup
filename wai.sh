#!/bin/zsh

version=1.0.0

autoload -Uz colors
colors

zparseopts -D -F -E - \
    -all=_arg_all \
    s+:=_arg_script -script+:=_arg_script \
    h=_arg_help -help=_arg_help || exit 1

_arg_all=${#_arg_all}
_arg_script=${_arg_script[-1]}
_arg_help=${#_arg_help}

if [[ $_arg_help == 1 || ($_arg_all == 0  && -z $_arg_script) ]]; then
    cat <<EOF
Webflo Apps Installer (v${version})

Usage: $(basename $0) [OPTIONS]

Options:
  --all         install all applications (not working if -s is specified)
  --script  -s  application to install
  --help    -h  prints help
EOF
    exit 0
fi


declare appsdir=${WEBFLO_DIR:-$HOME/.webflo}/wai/apps

if [ ! -z $_arg_script ]; then
    if [ ! -f $appsdir/$_arg_script.sh ]; then
        cat <<EOF
Script $fg[red]$_arg_script$reset_color not found
EOF
        exit 0
    fi
fi

declare bindir=$HOME/bin
declare zshdir=$HOME/.zsh
declare tempdir=/tmp/wai-files-$(date +%s)
declare spinnerfile=/tmp/wai-spinner-$(date +%s).log
declare logfile=/tmp/wai-$(date +%s).log


### Helpers functions

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

spin() {
    local \
        pid=$1 \
        before_msg="$2" \
        after_msg="$3"
    local spinner
    local -a spinners
    spinners=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)

    # hide cursor
    tput civis

    while kill -0 $pid 2>/dev/null; do
        for spinner in "${spinners[@]}"; do
            if [[ -f $spinnerfile ]]; then
                rm -f $spinnerfile
                tput cnorm
                return 1
            fi
            sleep 0.05
            printf " $fg[white]$spinner$reset_color  $before_msg\r" 2>/dev/null
        done
    done

    if [[ -n $after_msg ]]; then
        printf "\033[2K"
        printf " $fg_bold[blue]\U2714$reset_color  $after_msg\n"
    fi 2>/dev/null

    # show cursor
    tput cnorm || true
}

execute() {
    local args arg title error
    local -a errors

    while (($# > 0)); do
        case "$1" in
        --title)
            title="$2"
            shift
            ;;
        --error)
            errors+=("$2")
            shift
            ;;
        -* | --*)
            return 1
            ;;
        *)
            args="$1"
            ;;
        esac
        shift
    done

    {
        for arg in "${args[@]}"; do
            ${~${=arg}} &>>/dev/null
            exitCode=$?
            # When an error causes
            if [[ $exitCode -ne 0 ]]; then
                # error mssages
                printf "\033[2K" 2>/dev/null
                printf \
                    "  $fg[yellow]\U26A0$reset_color  $title [$fg[red]FAILED$reset_color]\n" \
                    2>/dev/null
                printf "$exitCode\n" >"$spinnerfile"
                # additional error messages
                if (($#errors > 0)); then
                    for error in "${errors[@]}"; do
                        printf "     \U1f816 $error\n" 2>/dev/null
                    done
                fi
            fi
        done
    } &

    spin \
        $! \
        "$title" \
        "$title [$fg[green]SUCCEEDED$reset_color]"

    if [[ $? -ne 0 ]]; then
        printf "\033[2K" 2>/dev/null
        printf "\nOops \U2620 ... Try again!\n" 2>/dev/null
        exit 1
    fi
}

execute_app() {
    local app=$1
    execute \
        --title "$(basename ${app%.*})" \
        "source $app"
}

prerequisites() {
    aptx install curl git
}

traperr() {
    tput cnorm
}
trap traperr ERR

mkdir -p $tempdir $bindir $zshdir

cat <<EOF
    
    $fg[cyan]WAI$reset_color (webflo apps installer) \U1f4e6

EOF

execute \
    --title "Installing prerequisites" \
    "prerequisites"

if [[ ! -z "$_arg_script" ]]; then
    execute_app $appsdir/$_arg_script.sh
else if [[ $_arg_all == 1 ]]
    setopt null_glob
    setopt extended_glob
    for app in $appsdir/!(_*).sh(N); do
        execute_app $app
    done
fi

execute --title "Cleaning-up" "rm -rf $tempdir $logfile $spinnerfile"

cat <<EOF

    ${fg[yellow]}Done !$reset_color 
    please update your shell by closing up your terminal
EOF
