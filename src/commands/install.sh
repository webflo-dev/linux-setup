#!/bin/zsh

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

    for app in $apps; do
        execute_app $app
    done

    execute \
        --title "Cleaning-up" \
        "cleanup"

    cat <<EOF

    $fg[yellow]Done !$reset_color 

EOF


}
