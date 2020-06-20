#!/bin/bash

gpasswd -a $USER input;
aptx install xdotool wmctrl libinput-tools;

declare git_dir=$tempdir/libinput-gestures;

git clone https://github.com/bulletmark/libinput-gestures.git $git_dir;

cd $git_dir;
./libinput-gestures-setup install;
rm -rf $git_dir;

sudo -H -u $USER libinput-gestures-setup autostart;
sudo -H -u $USER libinput-gestures-setup start;

