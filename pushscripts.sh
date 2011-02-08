#!/bin/sh

source $(pullscripts)


git status
git add -A
git status
git commit -m "auto commit: $1"
git status

git push origin master

cd $current_location