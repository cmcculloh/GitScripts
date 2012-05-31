#!/bin/bash
## /*
#	@usage getbranch
#
#	@description
#	This script assertains your current branch name and copies it to your clipboard.
#	description@
#
#
#	@examples
#	1) getbranch
#	   # Will show your current branch name and tell you that it has been copied to your clipboard.
#	examples@
#
#	@dependencies
#	functions/5000.parse_git_branch.sh
#	dependencies@
#
#	@file getbranch.sh
## */
$loadfuncs


echo ${X}



branch=$(__parse_git_branch)

echo "Your current branch is: ${B}\`${branch}\`${X}."
echo -n $branch | pbcopy
echo "It has been copied to your clipboard."
echo
echo ${X}

exit
