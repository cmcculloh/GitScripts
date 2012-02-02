#!/bin/bash
$loadfuncs

cd ${flgitscripts_path}

source flpullscripts.sh

current_location=$(pwd)
current_branch=$(__parse_git_branch)

git status
git add -A
git status
git commit -m "auto commit: $1"
git status

git push origin $current_branch

cd $current_location