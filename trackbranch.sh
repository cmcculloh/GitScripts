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

	#echo "No branch name supplied, we have determined that it is: ${startingBranch}"


elif __branch_exists $1; then
	# parameter supplied --- and branch exists
	#echo "Branch exists!"
	startingBranch=$1
else
	# parameter supplied --- and branch does not exist
	echo ${E}"Error: a failure has occured."${X}
	echo ${E}"The branch supplied (${COL_CYAN}${1}${COL_NORM}) does not appear to exist. Exiting now."${X}
	exit 1

fi



echo ${H1}
echo ${H1HL}
echo "Going to set up a remote tracking branch for: ${COL_CYAN}${startingBranch}${COL_NORM}"
echo ${H1HL}
echo ${X}
echo



if __branch_merge_set $startingBranch; then
	echo ${STYLE_WARNING}"Alert: the branch ${COL_CYAN}${startingBranch}${COL_NORM}${STYLE_WARNING} is already tracking a remote branch. Exiting now."${X}
	exit 1
else
	echo "The branch ${COL_CYAN}${startingBranch}${COL_NORM} is not yet tracking a remote branch. Determining remote now..."
	remote=$(__get_remote)

	if [ -n "$remote" ]; then
		echo "Remote: ${COL_GREEN}${remote}${COL_NORM}"
		echo
		echo "$ git fetch --all --prune"
		git pull fetch --all --prune
		echo
		echo
		# if a remote exists, push to it.
		echo
		echo
		echo "Remote determined to be ${COL_CYAN}${remote}${COL_NORM}. Pushing to remote now..."
		echo ${O}${H2HL}
		echo "$ git push ${remote} ${startingBranch}"
		git push $remote $startingBranch
		echo ${H2HL}${X}
	fi

	echo ${H2HL}${X}
	git config branch.$startingBranch.remote $remote
	git config branch.$startingBranch.merge refs/heads/$startingBranch

	if __branch_merge_set $startingBranch; then
		exit 0
	else
		echo ${E}"Error: a failure has occured."${X}
		echo ${E}"Unable to set a tracking branch. Exiting now."${X}
		exit 1
	fi
	
fi

# git config --get branch.csc---make-command-to-set-up-remote-tracking-on-existing-branch.merge

