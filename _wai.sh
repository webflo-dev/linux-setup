# Completion script for WAI (webflo apps installer)

_wai() {

    local curcontext="$curcontext" state line
    integer ret=1
    typeset -A opt_args

    _arguments -C \
        '(- :)'{-h,--help}'[Get help]' \
        '(- :)'{-v,--version}'[Print version and exit]' \
        '--all[install all applications]' \
        '(-s --script)'{-s,--script}'[application to install]:'

    case "${words[CURRENT - 1]}" in
    -s | --script)
        local IFS=$'\n'
        workdir=${WEBFLO_HOME:-$HOME/.webflo}
        appsdir=${WEBFLO_WAI_DIR:-$workdir/apps}
        if [ -d $appsdir ]; then
            _values -C "scripts" ${$(find $appsdir -type f -iname "[^_*]*.sh" | sed -e "s#${appsdir}/\{0,1\}##" -e 's#\.sh##' -e 's#\\#\\\\#' | sort -V):-""}
        fi
        ;;
    esac
}

compdef _wai wai.sh
compdef _wai wai
