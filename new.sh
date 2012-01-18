#!/bin/bash

## /*
#	@usage new <branch_name> [from <existing_branch>]
#
#	@description
#	This script provides several ways to create a new branch. You will be able to create a branch
#	based off of:
#		1. Specified <existing_branch>
#		2. The current branch you are on
#		3. The master branch
#
#	In addition, the branches will automatically be tracked and pushed up to any remotes you have
#	configured. Don't worry, you will get the option to choose which remote you want the branch
#	pushed to if you have configured more than one.
#	description@
#
#	@notes
#	- You will end on the new branch. That is, it will be the currently checked out branch.
#	- The stash and reset options in the initial menu currently only work when your
#	starting branch is the master branch.
#	notes@
#
#	@examples
#	1) new some-work
#	2) new some-work from old-work
#	examples@
#
#	@dependencies
#	functions/0100.bad_usage.sh
#	functions/5000.branch_exists.sh
#	functions/5000.parse_git_status.sh
#	functions/5000.set_remote.sh
#	dependencies@
## */
$loadfuncs


echo ${X}

# first parameter required.
if [ -z "$1" ]; then
	echo
	__bad_usage new "New requires the new branch name as the first parameter."
	exit 1

#no reason to continue if user is trying to create a branch that already exists
elif __branch_exists_local "$1"; then
	echo
	echo ${E}"  Branch \`$1\` already exists! Aborting...  "${X}
	exit 1
fi

# default branch to start from, current branch, and any remotes
startingBranch="master"
currentBranch=$(__parse_git_branch)

#user may specify a different base branch
if [ -n "$2" ] && [ "$2" == "from" ]; then
	if [ -n "$3" ] && __branch_exists "$3"; then
		startingBranch="$3"
	else
		echo
		echo ${E}"  The specified base branch \`$3\` does not exist. Aborting...  "${X}
		exit 1
	fi
fi


echo ${H1}${H1HL}
echo "Creating new branch: ${H1B}\`${1}\`${H1}   "
echo ${H1HL}${X}
echo
echo
echo "This tells your local git about all changes on the remote. Then we'll check your git status."
echo ${O}${H2HL}
echo "$ git fetch --all --prune"
git fetch --all --prune
echo ${O}
echo
echo "$ git status"
git status
echo ${O}${H2HL}${X}
echo
echo ${I}" (1) -  Create branch ${STYLE_NEWBRANCH}\`${1}\`${I} from ${STYLE_OLDBRANCH_H1}\`${startingBranch}\`${I}"
echo "  2  -  Create branch ${STYLE_NEWBRANCH}\`${1}\`${I} from the current branch ${STYLE_OLDBRANCH_H1}\`${currentBranch}\`${I}"
echo "  3  -  Stash Changes and create branch ${STYLE_NEWBRANCH}\`$1\`${I} from ${STYLE_OLDBRANCH_H1}\`${startingBranch}\`${I}"
echo "  4  -  Revert all changes to tracked files (ignores untracked files), and create branch ${STYLE_NEWBRANCH}\`$1\`${I} from ${STYLE_OLDBRANCH_H1}\`${startingBranch}\`${I}"
echo "  5  -  Abort creation of branch ${STYLE_NEWBRANCH}\`$1\`${I} from ${STYLE_OLDBRANCH_H1}\`${startingBranch}\`${I}"${X}
echo
echo ${I}"Type the number of the choice you want and hit enter: "${X}
read decision

# must be a number or nothing, otherwise abort
{ echo "$decision" | egrep -q '^[1-5]$'; } || {
	[ -z "$decision" ] && decision=1
} || { decision=5; }

echo
echo ${O}"You chose: $decision"${X}
echo

# handle decision cases
case $decision in

	# create new branch from master or specified branch
	1)
		echo ${O}"Continuing..."${X};;

	# create new branch from whatever branch user is currently on
	2)
		startingBranch=$currentBranch
		echo "Base branch changed to: ${B}\`${startingBranch}\`${X}"
		echo
		echo "Continuing...";;

	# stash changes and create branch from master or specified branch
	3)
		echo "This ${A}stashes${X} any local changes you might have made and forgot to commit."
		echo "To apply these changes later, use: ${A}git stash apply"${X}
		echo ${O}${H2HL}
		echo "$ git stash"
		git stash
		echo ${O}
		echo

		echo "$ git status"
		git status
		echo ${O}${H2HL}${X};;

	# revert changes to tracked files and create new branch from master or specified branch
	4)
		echo "This attempts to ${A}reset${X} your current branch to the last check-in."
		echo "If you have made any changes to untracked files, they will NOT be affected."
		echo ${O}${H2HL}
		echo "$ git reset --hard"
		git reset --hard
		echo ${O}
		echo

		echo "$ git status"
		git status
		echo ${O}${H2HL}${X};;

	# abort process
	5)
		echo "Aborting creation of branch ${B}\`${1}\`"${X}
		exit 1;;

	# input invalid. abort process
	*)
		echo "Invalid or no choice given. Aborting..."
		exit 1;;

esac


echo
echo
echo "Configuring remotes, if any..."
__set_remote


if [ "$startingBranch" = "master" ]; then
	echo
	echo
	echo "This branches ${B}\`master\`${X} to create a new branch named ${B}\`$1\`${X}"
	echo "and then checks out the ${B}\`$1\`${X} branch. We will make sure"
	echo "to get all updates (if available) to ${B}\`master\`${X} as well."
	echo ${O}${H2HL}

	echo "$ git checkout -b $1 $_remote/master"
	git checkout -b "$1" "$_remote"/master
	echo ${O}${H2HL}${X}
else
	echo
	echo
	echo "You are about to ${A}checkout${X} branch ${B}\`${startingBranch}\`${X} in order to create a new branch named ${B}\`$1\`${X}."
	echo "Do not do this unless you truly know what you are doing, and why!"
	echo "The only reason to do this is if your new branch relies on branch ${B}\`${startingBranch}\`${X}."
	echo "Please type '${I}I understand${X}' (${W}case sensitive!${X}) and hit enter to continue. Any other input"
	echo "will abort this process:"
	read iunderstand

	if [ "$iunderstand" == "I understand" ]; then
		echo
		echo
		echo "This branches ${B}\`${startingBranch}\`${X} to create a new branch named ${B}\`$1\`${X}"
		echo ${O}${H2HL}
		echo "$ git checkout -b ${1} ${startingBranch}"
		git checkout -b $1 $startingBranch
		echo ${O}${H2HL}${X}
	else
		echo
		echo 'You have chosen.... wisely. Exiting script...'
		exit 1
	fi
fi


#set up tracking for when the branch later gets pushed
git config branch.$1.remote $_remote
git config branch.$1.merge refs/heads/$1


# do this later in the push.sh script. Leaving here in case
# we want a flag that you can set in your config that auto-pushes
# new branches...

# if a remote exists, push to it.
# if [ -n "$_remote" ]; then
# 	echo
# 	echo
# 	echo "Finally, your new branch will be pushed up to the remote: ${COL_GREEN}${_remote}${COL_NORM}"
# 	echo ${O}${H2HL}
# 	echo "$ git push ${_remote} ${1}"
# 	git push "$_remote" "$1"
# 	echo ${O}${H2HL}${X}
# fi

exit