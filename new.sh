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
#	gitscripts/gsfunctions.sh
#	dependencies@
## */
$loadfuncs


# first parameter required.
if [ -z "$1" ]; then
	echo
	__bad_usage new "New requires the new branch name as the first parameter."
	exit 1

#no reason to continue if user is trying to create a branch that already exists
elif __branch_exists $1; then
	echo
	echo ${E}"Branch \`$1\` already exists! Aborting..."${X}
	exit 1
fi

# default branch to start from, current branch, and any remotes
startingBranch="master"
currentBranch=$(__parse_git_branch)
remote=$(__get_remote)

#user may specify a different base branch
if [ -n "$2" ] && [ "$2" == "from" ]; then
	if [ -n "$3" ] && __branch_exists "$3"; then
		startingBranch=$3
	else
		echo
		echo ${E}"The base branch specified ($3) does not exist. Aborting..."${X}
		echo
		exit 1
	fi
fi


echo ${H1}
echo ${H1HL}
echo "Creating new branch: ${STYLE_NEWBRANCH_H1}\`${1}\`${H1}   "
echo ${H1HL}
echo ${X}
echo
echo
echo "This tells your local git about all changes on the remote. Then we'll check your git status."
echo ${O}${H2HL}
echo "$ git fetch --all --prune"
git fetch --all --prune
echo
echo
echo "$ git status"
git status
echo ${H2HL}${X}${I}
echo
echo " (1) -  Create branch ${STYLE_NEWBRANCH}\`${1}\`${I} from ${STYLE_OLDBRANCH_H1}\`${startingBranch}\`${I}"
echo "  2  -  Create branch ${STYLE_NEWBRANCH}\`${1}\`${I} from the current branch ${STYLE_OLDBRANCH_H1}\`${currentBranch}\`${I}"
echo "  3  -  Stash Changes and create branch ${STYLE_NEWBRANCH}\`$1\`${I} from ${STYLE_OLDBRANCH_H1}\`${startingBranch}\`${I}"
echo "  4  -  Revert all changes to tracked files \(ignores untracked files\), and create branch ${STYLE_NEWBRANCH}\`$1\`${I} from ${STYLE_OLDBRANCH_H1}\`${startingBranch}\`${I}"
echo "  5  -  Abort creation of branch ${STYLE_NEWBRANCH}\`$1\`${I} from ${STYLE_OLDBRANCH_H1}\`${startingBranch}\`${I}"
echo ${X}
echo ${I}"Type the number of the choice you want and hit enter: "
read decision
[ -n "$decision" ] || decision=1
echo ${X}
echo ${O}"You chose: $decision"
echo

# handle decision cases
case $decision in

	# create new branch from master or specified branch
	1)
		echo "Continuing...";;

	# create new branch from whatever branch user is currently on
	2)
		startingBranch=$currentBranch
		echo "Base branch changed to: ${COL_CYAN}${startingBranch}${COL_NORM}"
		echo
		echo "Continuing...";;

	# stash changes and create branch from master or specified branch
	3)
		echo ${X}"This stashes any local changes you might have made and forgot to commit."
		echo "To apply these changes later, use: ${COL_MAG}git stash apply"${X}
		echo ${O}${H2HL}
		echo "$ git stash"
		git stash
		echo
		echo

		echo "$ git status"
		git status
		echo ${H2HL}${X};;

	# revert changes to tracked files and create new branch from master or specified branch
	4)
		echo ${X}"This attempts to reset your current branch to the last check-in."
		echo "If you have made any changes to untracked files, they will NOT be affected."
		echo ${O}${H2HL}
		echo "$ git reset --hard"
		git reset --hard
		echo
		echo

		echo "$ git status"
		git status
		echo ${H2HL}${X};;

	# abort process
	5)
		echo "Aborting creation of branch ${STYLE_NEWBRANCH}\`${1}\`${X}"
		exit 1;;

	# input invalid. abort process
	*)
		echo "Invalid or no choice given. Aborting..."${X}
		exit 1;;

esac


if [ "$startingBranch" == "master" ]; then
	echo "This branches master to create a new branch named ${COL_CYAN}$1${COL_NORM}"
	echo "and then checks out the ${COL_CYAN}$1${COL_NORM} branch. We will make sure"
	echo "to get all updates (if available) to master as well."
	echo ${O}${H2HL}

	# only checkout master if it isn't already
	if [ "$currentBranch" != "master" ]; then
		echo "$ git checkout master"
		git checkout master
		echo
		echo
	fi

	if [ -n "$remote" ]; then
		echo "Remote: ${COL_GREEN}${remote}${COL_NORM}"
		echo
		echo "$ git pull ${remote} master"
		git pull $remote master
		echo
		echo
	fi

	echo "$ git checkout -b $1"
	git checkout -b $1
	echo ${H2HL}${X}
	git config branch.$1.remote $remote
	git config branch.$1.merge refs/heads/$1
else
	echo "You are about to checkout branch ${COL_CYAN}${startingBranch}${COL_NORM} in order to create a new branch named ${COL_CYAN}$1${COL_NORM}."
	echo "Do not do this unless you truly know what you are doing, and why!"
	echo "The only reason to do this is if your new branch relies on branch ${COL_CYAN}${startingBranch}${COL_NORM}."
	echo "Please type '${I}I understand${X}' (case sensitive!) and hit enter to continue. Any other input"
	echo 'will abort this process:'
	read iunderstand

	if [ "$iunderstand" == "I understand" ]; then
		echo
		echo
		echo "This branches ${COL_CYAN}${startingBranch}${COL_NORM} to create a new branch named ${COL_CYAN}$1${COL_NORM}"
		echo ${O}${H2HL}
		if [ "$currentBranch" != "$startingBranch" ]; then
			echo "$ git checkout -b ${1} ${startingBranch}"
			git checkout -b $1 $startingBranch
		else
			echo "$ git branch ${1}"
			git branch $1
			echo
			echo
			echo "$ git checkout ${1}"
			git checkout $1
		fi
		git config branch.$1.remote $remote
		git config branch.$1.merge refs/heads/$1
		echo ${H2HL}${X}
	else
		echo
		echo 'You have chosen.... wisely. Exiting script...'
		exit 1
	fi
fi

# if a remote exists, push to it.
if [ -n "$remote" ]; then
	echo
	echo
	echo "Finally, your new branch will be pushed up to the remote: ${COL_GREEN}${remote}${COL_NORM}"
	echo ${O}${H2HL}
	eval "$ git push ${remote} ${1}"
	git push $remote $1
	echo ${H2HL}${X}
fi

exit