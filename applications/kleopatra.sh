#!/bin/bash

declare gpg=$homedir/florent.gpg;

if [ -d $gpg ]; then
    kleopatra -i $gpg;
fi