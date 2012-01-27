#!/bin/bash
$loadfuncs

current_location=$(pwd)
cd ${flgitscripts_path}

current_branch=$(__parse_git_branch)

git fetch --all --prune
git checkout master
git pull origin master
git checkout $current_branch

source refresh_bash_profile.sh

cd $current_location