#!/bin/bash

_git() {
    git -C $homedir $@
}

_git init
_git remote add origin https://github.com/webflo-dev/linux-config.git
_git fetch
_git checkout origin/main -ft
