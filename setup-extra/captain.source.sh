#!/bin/bash

if [[ ! -z $CAPTAIN_ROOT ]]; then
  cd $CAPTAIN_ROOT;
fi

function get_args() {
  local list=$all_args
  local delete=($project $cmd $service)
  for del in ${delete[@]}
  do
    list=(${list[@]/$del})
  done
  echo "${list[@]}"
}

function dc() {
  local command=$1
  docker-compose -f $project/docker-compose.yml -p $project $command $service $docker_args
}


i=0
for f in *; do
  if [ -d ${f} ]; then
    if test -f "$f/docker-compose.yml"; then
      projects[$i]=$f
      i=$(($i + 1))
    fi
  fi
done

if [[ ! " ${projects[@]} " =~ " $1 " ]]; then
  case $1 in
    'up'|'down')
      for project in "${projects[@]}"
      do
        [[ $1 == 'up' ]] && dc 'up -d' || dc 'down';
      done
      exit
    ;;
    *)
      echo "Global action not supported (up, down) or project not found in $PWD"
      printf "\u279c %s\n" "${projects[@]}"
      exit
    ;;
  esac
fi

project=$1
cmd=$2
service=$3
all_args=$@
docker_args=$(get_args)

case $2 in
'up')
  dc 'up -d'
  exit
  ;;
'down')
  if [[ ! -z $service ]]; then 
    docker stop $service; docker rm $service;
  else
    dc 'down'
  fi
  exit;
  ;;
'restart')
  dc 'restart'
  exit
  ;;
'config')
  dc 'config'
  exit
  ;;
'exec')
  dc "exec" $docker_args
  exit;
  ;;
'run')
  dc "run -it -rm" $docker_args
  exit;
  ;;
*)
  echo "command not supported. Expected: up, down, restart, exec, run, config"
  exit
  ;;
esac