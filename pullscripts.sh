#!/bin/sh

echo "test"

current_location=$(pwd)
cd ${gitscripts_path}


echo "test 2"

current_branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')

echo "before fetch"
git fetch --all --prune
echo "after fetch"
git checkout master
git pull origin master
git checkout $current_branch

echo "running refresh_bash_profile"
source refresh_bash_profile.sh
echo "ran refresh_bash_profile"

cd $current_location