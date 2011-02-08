#!/bin/sh

echo before pullscripts
source $(pullscripts)
echo after pullscripts

current_location=$(pwd)
cd ${gitscripts_path}

git status
git add -A
git status
git commit -m "auto commit: $1"
git status

git push origin master

cd $current_location