#!/bin/zsh

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
        printf " $fg_bold[green]✓$reset_color  $after_msg\n"
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
            #sleep 3
            #exitCode=1
            # When an error causes
            if [[ $exitCode -ne 0 ]]; then
                # error mssages
                printf "\033[2K" 2>/dev/null
                printf " $fg[red]✘$reset_color  $title\n" 2>/dev/null
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
        printf "\nOops  ...  Try again!\n" 2>/dev/null
        printf "\U1F4DD logs $logfile\n" 2>/dev/null
        exit 1
    fi
}

execute_app() {
    local app=$1
    execute \
        --title "$(basename ${app%.*})" \
        "source $app"
}
