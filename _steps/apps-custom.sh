#!/bin/bash

declare apps=$appsdir/*.sh;

function text() {
    echo ${BLUE}">> $@"${RESET};
}

step "Installing custom applications"
for app in $apps; do
    if [[ ! $app =~ '.source.sh'$ ]]; then
        text "$(basename "$app")"
        source $app;
    fi
done
