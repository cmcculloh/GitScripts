#!/bin/sh

source pullscripts.sh

current_location=$(pwd)
cd ${gitscripts_path}

current_branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')

git status
git add -A
git status
git commit -m "auto commit: $1"
git status

git push origin $current_branch

cd $current_location