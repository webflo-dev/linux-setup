#!/bin/zsh

autoload -Uz colors
colors

WEBFLO_DIR=${WEBFLO_DIR:-$HOME/.webflo}
WAI_DIR=$WEBFLO_DIR/wai
spinnerfile=/tmp/wai-spinner-$(date +%s).log
logfile=/tmp/wai-$(date +%s).log

trap_error() {
    tput cnorm
}
trap trap_error ERR

prerequisites() {
    if [[ "$((( $+commands[git] )))" == "0" ]]; then
        echo "git not found"
        return 1
    fi
    if [[ -d $WAI_DIR ]]; then
        echo "WAI is already installed: $WAI_DIR"
        return 1
    fi
    return 0
}

setup_wai() {
    local BIN_DIR=$HOME/bin

    git clone https://github.com/webflo-dev/wai.git $WAI_DIR
    mkdir -p $BIN_DIR

    ln -s $WAI_DIR/wai.sh $BIN_DIR/wai
    chmod u+x $WAI_DIR/wai.sh

    # sudo ln -s $WAI_DIR/_wai.sh /usr/local/share/zsh/site-functions/_wai
    ln -s $WAI_DIR/_wai.sh $HOME/.zsh/wai.zsh
}

cleanup() {
    rm -f /tmp/wai-*(N) /tmp/wai-spinner-*(N)
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
        printf " $fg_bold[green]\U2713$reset_color  $after_msg\n"
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
            ${~${=arg}} &>>$logfile
            exitCode=$?
            # When an error causes
            if [[ $exitCode -ne 0 ]]; then
                # error mssages
                printf "\033[2K" 2>/dev/null
                printf \
                    " $fg[red]\U2717$reset_color  $title\n" \
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
        "$title"

    if [[ $? -ne 0 ]]; then
        printf "\033[2K" 2>/dev/null
        printf "\n Oops \U2639 ... logs are available: \U1F4DD $logfile\n" 2>/dev/null
        exit 1
    fi
}

cat <<EOF
    
 $(printf "\U1F4E6") Installer for $fg_bold[cyan]WAI$reset_color (Webflo Apps Installer) 

EOF

execute \
    --title "Checking prerequisites" \
    --error "WAI is maybe already installed " \
    --error "Check if git is installed" \
    "prerequisites"

execute \
    --title "Installing WAI" \
    "setup_wai"

cat <<EOF

    $fg_bold[cyan]WAI$reset_color ${fg[yellow]}is now installed!$reset_color 
EOF
