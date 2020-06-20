#!/bin/bash

version=1.0.0

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
  local first_option all_short_options='ah'
  first_option="${1:0:1}"
  test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_app=
_arg_silent="off"
_arg_init="on"

print_version()
{
  printf '%s\n' "Linux-setup version $version";
}

print_help()
{
  printf 'Usage: %s [--no-init] [-a|--app <name>] [--silent] [--version]  [-h|--help]\n' "$0"
  printf '\t%s\n' "--no-init: do not run prerequisite install"
  printf '\t%s\n' "-a, --app: Specifiy app to install"
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
      -a|--app)
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
      --silent)
        _arg_silent="on"
        ;;
      --no-init)
        _arg_init="off"
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



#  List all [sections] of a .INI file
# sed -n 's/^[ \t]*\[\(.*\)\].*/\1/p' $ini_file

#  Read KEY from [SECTION]
#sed -n '/^[ \t]*\[SECTION\]/,/\[/s/^[ \t]*KEY[ \t]*=[ \t]*//p'

#  Read all values from SECTION in a clean KEY=VALUE form
#sed -n '/^[ \t]*\[SECTION\]/,/\[/s/^[ \t]*\([^#; \t][^ \t=]*\).*=[ \t]*\(.*\)/\1=\2/p'
parse_ini() {
    [[ -f $1 ]] || { echo "$1 is not a file." >&2;return 1;}
    if [[ -n $2 ]]
    then
        local -n config_array=$2
    else
        echo "array is required as second parameter" >&2; return 1;
    fi
    declare -Ag ${!config_array} || return 1
    declare -A section_values
    local line key value section
    local section_regex="^[[:blank:]]*\[([[:alpha:]_][[:alnum:]_]*)\][[:blank:]]*(#.*)?$"
    local entry_regex="^[[:blank:]]*([[:alpha:]_][[:alnum:]_]*)[[:blank:]]*=[[:blank:]]*('[^']+'|\"[^\"]+\"|[^#[:blank:]]+)[[:blank:]]*(#.*)*$"
    while read -r line
    do
        [[ -n $line ]] || continue
        [[ $line =~ $section_regex ]] && {
            if ([[ ! -z $section ]]); then
                config_array[$section]=$section_values;
            fi
            section=${BASH_REMATCH[1]}
            section_values=()
            continue
        }
        [[ $line =~ $entry_regex ]] || continue
        declare -A app_config;
        key=${BASH_REMATCH[1]}
        value=${BASH_REMATCH[2]#[\'\"]} # strip quotes
        value=${value%[\'\"]}
        section_values+='["'${key}'"]="'${value}'" '
    done < "$1"
}

aptx(){
  apt -y -qq $@;
}

add_apt_key(){
  curl -sSL $2 | apt-key add -;
  echo "deb [arch=amd64] $3 $4 $5" | tee /etc/apt/sources.list.d/$1.list;
}

add_apt_repository(){
  add-apt-repository $1;
}

download_file() {
  curl -sSL $1 -o $tempdir/$2;
}

setup_color;
parse_commandline "$@"


declare -A settings;
parse_ini ./setup.ini settings

apps=${!settings[@]};
if ([ ! -z "$_arg_app" ]); then
  declare -A config="(${settings[$_arg_app]})";
  if ([ ! -z config ]); then
    apps=( $_arg_app );
  fi
fi;

 echo ${apps[@]}


step "Updating system"
aptx update && aptx full-upgrade && aptx autoremove;


if ([ $_arg_init == 'on' ]); then
  step "Installing prerequisite"
  aptx install \
      apt-transport-https \
      software-properties-common \
      curl \
      wget \
      ca-certificates \
      gnupg-agent \
    ;
fi

declare workdir=$(pwd);
declare tempdir=$workdir/temporary_files;
declare stepdir=$workdir/steps;
declare homedir=/home/florent;
declare appsdir=$workdir/applications;
declare bindir=$homedir/bin;

mkdir -p $tempdir $bindir;
for app in ${apps[@]}; do
  echo "${BLUE}Installing: $app${RESET}"
  declare -A config="(${settings[${app}]})";
  type=${config["type"]};
  name=${config["name"]};
  [ -z "$name" ] && name=$app;

  case $type in
    'deb')
      url=${config["url"]};
      [ -z $url ] && echo "url is missing" && continue;
      file="$app.deb";
      download_file $url $file;
      aptx install $tempdir/$file;
      rm $tempdir/$file;
      continue;
    ;;
    'apt')
      ppa=${config["ppa"]};
      key=${config["key"]};
      if [ ! -z $ppa ]; then
        add_apt_repository $ppa;
        aptx update;
      elif [ ! -z $key ]; then
        add_apt_key $name $key ${config["url"]} ${config["distrib"]} ${config["component"]};
        aptx update;
      fi
      aptx install $name;
    ;;
    'custom')
      source $appsdir/$name.sh;
      continue;
    ;;
    *)
      echo "Type not supported: "$type
      continue;
    ;;
  esac
done;

step "Cleaning up temp files"
rm -rf $tempdir;

if [ ! -z /bin/zsh ]; then
  step "Changing shell to ZSH"
  chsh -s /bin/zsh
fi

echo ${YELLOW}"Done ! Please close your terminal for updating shell"${RESET}
