#!/bin/zsh

version=1.0.0

autoload -Uz colors
colors

zparseopts -D -F - a+:=_arg_app -app+:=_arg_app h=_arg_help -help=_arg_help || exit 1

_arg_app=${_arg_app[-1]}
_arg_help=${#_arg_help}

if [[ $_arg_help == 1 ]]; then
    cat <<EOF
Linux-setup (v${version})

Usage: $(basename $0) [OPTIONS]

Options:
  -a, --a       application to install
  -h, --help    prints help
EOF
    exit 0
fi

declare workdir=$(pwd)
declare appsdir=$workdir/applications

if [ -z $_arg_app ]; then
    if [ ! -f $appsdir/$_arg_app.sh ]; then
        cat <<EOF
Application not found: $_arg_app
Use completion to see avalaible applications.
EOF
        exit 0
    fi
fi

declare tempdir=$workdir/temporary_files
declare stepdir=$workdir/steps
declare homedir=/home/florent
declare bindir=$homedir/bin
declare spinnerfile=$workdir/tmp.log
declare logfile=$workdir/setup.log

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
    curl -sSL $1 -o $tempdir/$2
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
    bash $tempdir/$file
}

get_latest_release_github() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" |
        grep '"tag_name":' |
        sed -E 's/.*"([^"]+)".*/\1/'
}

spin() {
    local \
        before_msg="$1" \
        after_msg="$2"
    local spinner
    local -a spinners
    spinners=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)

    # hide cursor
    tput civis

    while true; do
        for spinner in "${spinners[@]}"; do
            if [[ -f $spinnerfile ]]; then
                rm -f $spinnerfile
                tput cnorm
                return 1
            fi
            sleep 0.05
            printf " $fg[white]$spinner$reset_color  $before_msg\r" 2>/dev/null
        done
        [ $#jobstates = 0 ] && break
    done

    if [[ -n $after_msg ]]; then
        printf "\033[2K"
        printf " $fg_bold[blue]\U2714$reset_color  $after_msg\n"
    fi 2>/dev/null

    # show cursor
    tput cnorm || true
}

execute() {
    local arg title error
    local -a args errors

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
            args+=("$1")
            ;;
        esac
        shift
    done

    {
        for arg in "${args[@]}"; do
            ${~${=arg}} &>>$logfile
            # When an error causes
            if [[ $status -ne 0 ]]; then
                # error mssages
                printf "\033[2K" 2>/dev/null
                printf \
                    " $fg[yellow]\U26A0$reset_color  $title [$fg[red]FAILED$reset_color]\n" \
                    2>/dev/null
                printf "$status\n" >"$spinnerfile"
                # additional error messages
                if (($#errors > 0)); then
                    for error in "${errors[@]}"; do
                        printf "    -> $error\n" 2>/dev/null
                    done
                fi
            fi
        done
    } &

    spin \
        "$title" \
        "$title [$fg[green]SUCCEEDED$reset_color]"

    if [[ $status -ne 0 ]]; then
        printf "\033[2K" 2>/dev/null
        printf "Oops \U2620 ... Try again!\n" 2>/dev/null
        exit 1
    fi
}

execute_app() {
    local app=$1
    execute \
        --title "$(basename ${app%.*})" \
        "source $app"
}

traperr() {
    tput cnorm
}
trap traperr ERR

mkdir -p $tempdir $bindir
echo >$logfile

clear

cat <<EOF
    
    $fg[cyan]Linux setup$reset_color \U1f4e6

EOF

execute \
    --title "Installing prerequisites" \
    "aptx install curl wget git"

if [[ ! -z "$_arg_app" ]]; then
    execute_app $appsdir/$_arg_app.sh
else
    for app in $appsdir/!(_*).sh; do
        execute_app $app
    done
fi

execute --title "Cleaning-up" "rm -rf $tempdir $logfile"

cat <<EOF

    ${fg[yellow]}Done !$reset_color 
    please update your shell by closing up your terminal
EOF
printf '%s' $_heredoc
