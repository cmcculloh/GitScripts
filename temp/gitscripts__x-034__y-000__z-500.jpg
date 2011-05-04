#!/bin/sh

current_location=$(pwd)
cd ${gitscripts_path}

current_branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')

git fetch --all --prune
git checkout master
git pull origin master
git checkout $current_branch

source refresh_bash_profile.sh

cd $current_location