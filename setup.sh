#!/bin/bash


die()
{
  local _ret=$2
  test -n "$_ret" || _ret=1
  test "$_PRINT_HELP" = yes && print_help >&2
  echo "$1" >&2
  exit ${_ret}
}


begins_with_short_option()
{
  local first_option all_short_options='sh'
  first_option="${1:0:1}"
  test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_step=
_arg_silent="off"
_arg_init="off"


print_help()
{
  printf 'Usage: %s [-s|--step <arg>] [--silent] [--version]  [-h|--help]\n' "$0"
  printf '\t%s\n' "--init: Install prerequisite (used only when step if specified)"
  printf '\t%s\n' "-s, --step: Specifiy step to run individually"
  # printf '\t%s\n' "-ca, --custom-app: Specifiy custom app to install"
  printf '\t%s\n' "--silent: Activating silent mode"
  printf '\t%s\n' "--version: Prints version"
  printf '\t%s\n' "-h, --help: Prints help"
}

parse_commandline()
{
  while test $# -gt 0
  do
    _key="$1"
    case "$_key" in
      -s|--step)
        test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
        _arg_step="$2"
        shift
        ;;
      --step=*)
        _arg_step="${_key##--step=}"
        ;;
      -s*)
        _arg_step="${_key##-s}"
        ;;
      --version)
        exit 0
        ;;
      --silent)
        _arg_silent="on"
        ;;
      --init)
        _arg_init="on"
        ;;
      -h|--help)
        print_help
        exit 0
        ;;
      -h*)
        print_help
        exit 0
        ;;
      *)
        _PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$1'" 1
        ;;
    esac
    shift
  done
}

setup_color() {
	# Only use colors if connected to a terminal
	if [ -t 1 ]; then
		RED=$(printf '\033[31m')
		GREEN=$(printf '\033[32m')
		YELLOW=$(printf '\033[33m')
		BLUE=$(printf '\033[34m')
		BOLD=$(printf '\033[1m')
		RESET=$(printf '\033[m')
	else
		RED=""
		GREEN=""
		YELLOW=""
		BLUE=""
		BOLD=""
		RESET=""
	fi
}

error() {
	echo ${RED}"Error: $@"${RESET} >&2
}

step() {
    echo ${GREEN}"===== $@"${RESET}
}

aptx() {
	apt -y -qq $@
}

setup_color;
parse_commandline "$@"

declare workdir=$(pwd);
declare tempdir=$workdir/temporary_files;
declare stepdir=$workdir/steps;
declare homedir=/home/florent;
declare appsdir=$workdir/applications;
declare bindir=$homedir/bin;


mkdir -p $tempdir $bindir;

steps=( "init" "ppa" "apt-sources" "apps-apt" "apps-deb" "postprocessing" );
if [ ! -z $_arg_step ]; then
  steps=($_arg_step)
  [[ $_arg_init == 'on' ]] && steps=("init" "${steps[@]}");
fi


for step in "${steps[@]}"
do
    source $workdir/steps/$step.sh;
done


echo "Installation DONE !"
