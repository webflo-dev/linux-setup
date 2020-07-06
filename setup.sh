#!/bin/bash

version=1.0.0
_arg_app=
_arg_init="on"

### Command line functions
print_version() {
  printf '%s\n' "Linux-setup version $version"
}

print_help() {
  printf 'Usage: %s [--no-init] [-a|--app <name>] [--version]  [-h|--help]\n' "$0"
  printf '\t%s\n' "--no-init: do not run prerequisite install"
  printf '\t%s\n' "-a, --app: Specifiy app to install"
  printf '\t%s\n' "--version: Prints version"
  printf '\t%s\n' "-h, --help: Prints help"
}

die() {
  local _ret=$2
  test -n "$_ret" || _ret=1
  test "$_PRINT_HELP" = yes && print_help >&2
  echo "$1" >&2
  exit ${_ret}
}

begins_with_short_option() {
  local first_option all_short_options='ah'
  first_option="${1:0:1}"
  test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

parse_commandline() {

  while test $# -gt 0; do
    _key="$1"
    case "$_key" in
    -a | --app)
      test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
      _arg_app="$2"
      shift
      ;;
    --app=*)
      _arg_app="${_key##--app=}"
      ;;
    --version)
      print_version
      exit 0
      ;;
    --no-init)
      _arg_init="off"
      ;;
    -h | --help)
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

### Parse INI files
parse_ini() {
  [[ -f $1 ]] || {
    echo "$1 is not a file." >&2
    return 1
  }
  if [[ -n $2 ]]; then
    local -n ini_settings=$2
  else
    echo "array is required as second parameter" >&2
    return 1
  fi
  declare -Ag ${!ini_settings} || return 1

  if ([ ! -z "$3" ]); then
    sections=($3)
  else
    sections=$(sed -n 's/^[ \t]*\[\(.*\)\].*/\1/p' $1)
  fi

  for section in ${sections[@]}; do
    ini_settings[$section]=$(sed -n "/^[ \t]*\[$section\]/,/\[/s/^[ \t]*\([^#; \t][^ \t=]*\).*=[ \t]*\(.*\)/[\1]=\2/p" $1)
  done
}

### Helpers functions
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

install_prerequisites() {
  echo ${GREEN}"===== Installing prerequisite"${RESET}
  aptx install \
    apt-transport-https \
    software-properties-common \
    curl \
    wget \
    git \
    ca-certificates \
    gnupg-agent \
    ;
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

setup_color
parse_commandline "$@"

declare -A settings
parse_ini ./setup.ini settings $_arg_app

declare workdir=$(pwd)
declare tempdir=$workdir/temporary_files
declare stepdir=$workdir/steps
declare homedir=/home/florent
declare appsdir=$workdir/applications
declare bindir=$homedir/bin

mkdir -p $tempdir $bindir

echo ${GREEN}"===== Updating system"${RESET}
aptx update && aptx full-upgrade && aptx autoremove

if ([ $_arg_init == 'on' ]); then install_prerequisites; fi

for section in ${!settings[@]}; do
  declare -A config="(${settings[${section}]})"
  app=${config["name"]}
  type=${config["type"]}
  [ -z "$app" ] && app=$section

  echo "${BLUE}Installing: $app${RESET}"

  case $type in
  'deb')
    install_deb $app ${config["url"]}
    ;;
  'apt')
    install_apt $app ${config["ppa"]} ${config["key"]} ${config["url"]} ${config["distrib"]} ${config["component"]}
    ;;
  'script')
    install_script $app ${config["url"]}
    ;;
  'custom')
    source $appsdir/$app.sh
    ;;
  *)
    echo "Application type not supported: "$type
    ;;
  esac
done

echo ${GREEN}"===== Cleaning up temp files"${RESET}
rm -rf $tempdir

if [ ! -z /bin/zsh ] && [ -z $_arg_app ]; then
  echo ${GREEN}"===== Changing shell to ZSH"${RESET}
  chsh -s /bin/zsh
fi

echo ${YELLOW}"Done ! Please close your terminal for updating shell"${RESET}
