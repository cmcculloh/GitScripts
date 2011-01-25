#!/bin/sh

current_location=$(pwd)

cd ${gitscripts_path}
git fetch --all --prune
git pull origin master
source refresh_bash_profile.sh

cd $current_location