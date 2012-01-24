#!/bin/bash
## /*
#	@usage gitdiff [base-branch-name]
#
#	@description
#	This script is used to get a quick look at all the files that have been added,
#	modified, and/or deleted in the current branch's latest commit and either a
#	specified branch (the first parameter) or the master branch (default).
#	description@
#
#	@notes
#	- If your project does not have a master branch, you will need to pass the first
#	parameter for each use.
#	notes@
#
#	@examples
#	1) gitdiff stage      # Shows file changes between the stage branch and HEAD
#	examples@
#
#	@dependencies
#	functions/5000.branch_exists.sh
#	dependencies@
#
#	@file gitdiff.sh
## */
$loadfuncs


echo
branch="master"
if [ -n "$1" ]; then
	branch=$1
fi

# make sure branch exists
if ! __branch_exists "$branch"; then
	echo ${E}"  Branch \`$branch\` does not exist! Aborting...  "${X}
	exit 1
fi

# get 7 digit shortened hash for each commit
hashFrom=$(git rev-parse --short $branch)
hashTo=$(git rev-parse --short HEAD)

echo ${O}${H2HL}
echo "$ git diff --name-status $hashFrom..$hashTo"
echo
echo "git diff --name-status ${hashFrom}..${hashTo}"
git diff --name-status $hashFrom..$hashTo
echo
echo "git diff -w $hashFrom..$hashTo"
echo ${H2HL}${X}
echo
echo ${Q}"Do diff? y (n)"${X}
read yn
if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
	git diff -w $hashFrom..$hashTo
fi

exit
