#!/bin/bash

## /*
#	@usage trackbranch [<branch_name>] 
#
#	@description
#	This script allows an easy way to set the upstream for an existing branch. 
#	
#	If there is a remote branch of the same name in existance, it will choose it.
#	
#	If it does not find a remote branch it will push the <branch_name> to the remote.
#	
#	It will then set the upstream for the local branch to the remote branch of the same name.
#	description@
#
#	@notes
#	- It uses the git command git branch --set-upstream foo upstream/foo
#	notes@
#
#	@examples
#	1) trackbranch
#	2) trackbranch foo
#	examples@
#
#	@dependencies
#	gitscripts/gsfunctions.sh
#	dependencies@
## */
$loadfuncs


if [ -z "$1" ]; then
	# no parameter supplied, we shall determine current branch
	startingBranch=$(__parse_git_branch)
	if [ -z "$startingBranch" ]; then
		echo ${E}"Error: a failure has occured."${X}
		echo ${E}"Unable to determine current branch, and a branch name was not supplied. Exiting now."${X}
		exit 1
	fi

	echo "No branch name supplied, we have determined that it is: ${startingBranch}"

	echo "Will check to see if it is being tracked already..."
	if __branch_merge_set $startingBranch; then
		echo "It is already tracked."
		exit 1
	else
		echo "It is NOT already tracked."
	fi

elif __branch_exists $1; then
	# parameter supplied --- and branch exists
	echo "Branch exists!"
	startingBranch=$1
else
	# parameter supplied --- and branch does not exist
	echo ${E}"Error: a failure has occured."${X}
	echo ${E}"The branch supplied (${1}) does not appear to exist. Exiting now."${X}
	exit 1

fi



# git config --get branch.master.merge
# git config --get branch.csc---make-command-to-set-up-remote-tracking-on-existing-branch.merge

