#!/bin/bash

declare gpg=/home/florent/florent.gpg;

if [ -d $gpg ] then;
    kleopatra -i $gpg;
fi