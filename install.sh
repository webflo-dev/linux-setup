#!/bin/zsh

autoload -Uz colors
colors

WEBFLO_DIR=${WEBFLO_DIR:-$HOME/.webflo}
WAI_DIR=$WEBFLO_DIR/wai
spinnerfile=/tmp/wai-spinner-$(date +%s).log
logfile=/tmp/wai-$(date +%s).log

cleanup() {
    tput cnorm
}
trap cleanup ERR

prerequisites() {
    if ( !(( $+commands[git])) );then
        return 1
    fi
    if [[ -d $WAI_DIR ]]; then
        return 1;
    fi
    return 0
}

setup_wai() {
    local BIN_DIR=$HOME/bin

    git clone https://github.com/webflo-dev/wai.git $WAI_DIR
    mkdir -p $BIN_DIR

    # install bin
    ln -s $WAI_DIR/wai.sh $BIN_DIR/wai
    chmod u+x $WAI_DIR/wai.sh

    # install completion
    ln -s $WAI_DIR/_wai.sh /usr/local/share/zsh/site-functions/_wai
    # ln -s $WAI_DIR/_wai.sh $HOME/.zsh/wai.zsh
    return 0
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

cat <<EOF
    
    $(printf "\U1F4E6") Installer for $fg_bold[cyan]WAI$reset_color (Webflo Apps Installer) 

EOF

execute \
    --title "Checking prerequisites" \
    --error "Does WAI already exists?" \
    --error "Is 'git' installed?" \
    "prerequisites"

execute \
    --title "Installing WAI" \
    --error "i am an error message" \
    "setup_wai"

cat <<EOF

    $fg_bold[cyan]WAI$reset_color ${fg[yellow]}is now installed!$reset_color 
EOF
