#!/bin/bash
# contains
# checks to see which other branches the branch you specify has merged into it


TEXT_BRIGHT=$'\033[1m'
TEXT_DIM=$'\033[2m'
TEXT_NORM=$'\033[0m'
COL_RED=$'\033[31m'
COL_GREEN=$'\033[32m'
COL_VIOLET=$'\033[34m'
COL_YELLOW=$'\033[33m'
COL_MAG=$'\033[35m'
COL_CYAN=$'\033[36m'
COL_WHITE=$'\033[37m'
COL_NORM=$'\033[39m'

branch=$1
if [ -z "$branch" ]
	then
	#use current branch if none specifid
	branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
fi

echo "##########################################"
echo "Running contains on ${COL_CYAN}$branch${COL_NORM}"
echo "##########################################"
echo
echo

echo "git branch --contains \"$branch\""
git branch --contains $1
