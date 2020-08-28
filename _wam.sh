# Completion script for WAM (webflo apps manager)

_wam() {

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
        _values -C "toto" "blabla" "plouf"
        local IFS=$'\n'
        WEBFLO_DIR=${WEBFLO_DIR:-$HOME/.webflo}
        WAM_DIR=$WEBFLO_DIR/wam
        appsdir=$WAM_DIR/apps
        if [ -d $appsdir ]; then
            _values -C "scripts" ${$(find $appsdir -type f -iname "[^_*]*.sh" | sed -e "s#${appsdir}/\{0,1\}##" -e 's#\.sh##' -e 's#\\#\\\\#' | sort -V):-""}
        fi
        ;;
    esac
}

compdef _wam wam wam.sh
