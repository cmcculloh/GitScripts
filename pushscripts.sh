#!/bin/sh

current_location=$(pwd)

cd ${gitscripts_path}

git pull origin master

refresh_bash_profile

#put you back in the right spot since refresh_bash_profile switches your directories...
cd ${gitscripts_path}

git status
git add -A
git status
git commit -m "auto commit: $1"
git status

git push origin master

cd $current_location