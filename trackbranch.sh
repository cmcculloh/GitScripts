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
#	*checkout.sh
#	clear-screen.sh
#	functions/5000.branch_merge_set.sh
#	functions/5000.branch_exists_local.sh
#	functions/5000.branch_exists_remote.sh
#	functions/5000.parse_git_branch.sh
#	functions/5000.set_remote.sh
#	dependencies@
## */
$loadfuncs


echo
if [ -z "$1" ]; then
	# no parameter supplied, we shall determine current branch
	startingBranch=$(__parse_git_branch)
	if [ -z "$startingBranch" ]; then
		echo ${E}"  Error: A failure has occurred.  "${X}
		echo ${E}"  Unable to determine current branch, and a branch name was not supplied. Exiting now.  "${X}
		exit 1
	fi

elif __branch_exists_local $1; then
	# parameter supplied --- and branch exists
	echo "Local branch exists!"
	startingBranch=$1

elif __branch_exists_remote $1; then
	# parameter supplied --- and branch exists
	echo ${O}${H2HL}${X}
	echo ${Q}"Branch does not exist locally, but it does on the remote -- check it out? (y) n"${X}
	echo ${O}${H2HL}${X}
	read decision
	if [ -z "$decision" ] || [ "$decision" = "" ] || [ "$decision" = "1" ]; then
		"${gitscripts_path}"checkout.sh "$1"
	fi
	echo
	startingBranch="$1"

else
	# parameter supplied --- and branch does not exist
	echo ${E}"  Error: a failure has occurred.  "
	echo "  The branch \`${1}\` does not appear to exist. Exiting now...  "${X}
	exit 1

fi


echo
echo ${H1}${H1HL}
echo "  Going to set up a remote tracking branch for: ${H1B}\`${startingBranch}\`${H1}  "
echo ${H1HL}${X}
echo
echo


if __branch_merge_set $startingBranch; then
	echo ${W}"Alert:${X} the branch ${B}\`${startingBranch}\`${X} is already tracking a remote branch. Exiting now..."
	exit 1
else
	echo "The branch ${B}\`${startingBranch}\`${X} is not yet tracking a remote branch. Determining remote now..."
	__set_remote

	if [ -n "$_remote" ]; then
		echo
		echo "Remote: ${COL_GREEN}${_remote}${COL_NORM}"
		echo
		echo ${O}${H2HL}
		echo "$ git fetch --all --prune"
		git fetch --all --prune
		echo ${O}${H2HL}${X}
		echo
		echo
		# if a remote exists, push to it.
		echo "Remote determined to be ${COL_GREEN}${_remote}${COL_NORM}. Pushing to remote now..."
		echo ${O}${H2HL}
		echo "$ git push ${_remote} ${startingBranch}"
		git push $_remote $startingBranch
		echo ${O}${H2HL}${X}
	fi

	echo ${O}${H2HL}${X}
	git config branch.$startingBranch.remote $_remote
	git config branch.$startingBranch.merge refs/heads/$startingBranch

	if __branch_merge_set "$startingBranch"; then
		exit 0
	else
		echo
		echo ${E}"  Error: a failure has occurred.  "
		echo "  Unable to set a tracking branch. Exiting now...  "${X}
		exit 1
	fi

fi

"${gitscripts_path}"clear-screen.sh

exit
