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
#
#	@file new.sh
## */
$loadfuncs


echo ${X}

# default branch to start from, current branch, and any remotes
startingBranch="master"
currentBranch=$(__parse_git_branch)

# first parameter required.
if [ -z "$1" ]; then
	echo
	__bad_usage new "New requires the new branch name as the first parameter."
	exit 1
fi

echo
echo
echo "Configuring remotes, if any..."
__set_remote

#no reason to continue if user is trying to create a branch that already exists
if __branch_exists_local "$1"; then
	echo
	echo ${E}"  Branch \`$1\` already exists!  "${X}
	read checkoutdecision
	if [ -z "$checkoutdecision" ] || [ "$checkoutdecision" = "y" ]; then
		${gitscripts_path}checkout.sh "$1"
	fi
	#don't create new branch since we checked the local copy out, just exit...
	exit 1
elif __branch_exists_remote "$1"; then
	echo
	echo ${E}"  Branch \`$1\` already exists on the remote!  "${X}
	echo ${Q}"  Check \`$1\` out from remote? (y) n "${Q}
	read checkoutremotedecision
	if [ -z "$checkoutremotedecision" ] || [ "$checkoutremotedecision" = "y" ]; then
		startingBranch="${_remote}/${1}"
		checkoutremote=true
	else
		exit 1
	fi
fi

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


if  ! __parse_git_status clean; then
	declare -a choices
	choices[0]="${A}Stash${STYLE_MENU_OPTION} changes and and contiue "${X}
	choices[1]="${A}Reset${STYLE_MENU_OPTION} (revert) all changes to ONLY tracked files and continue"${X}
	choices[2]="${A}Commit${STYLE_MENU_OPTION} ALL changes and continue "${X}
	choices[3]="${A}Just continue, I want to move all my changes to the new branch..."${X}

	if __menu "${choices[@]}"; then
		echo ${X}

		# handle decision cases
		case $_menu_sel_index in
			# stash changes and continue
			1)
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

			# revert changes to tracked files and continue
			2)
				echo "This attempts to ${A}reset${X} your current branch to the last stable commit."
				echo "If you have made any changes to untracked files, they will NOT be affected."
				echo ${O}${H2HL}
				echo "$ git reset --hard"
				git reset --hard
				echo ${O}
				echo
				echo "$ git status"
				git status
				echo ${O}${H2HL}${X};;
			
			#commit changes and continue
			3)
				echo "Please enter a commit message"
				read commitmsg
				${gitscripts_path}commit.sh "$commitmsg" "-A";;

			#just keep going
			4)
				echo "Ignoring changes and continuing";;

			#abort process
			*)
				echo "Aborting creation of ${B}\`$1\`${X}..."
				exit 0;;
		esac
	else
		echo ${E}"  Unable to determine a course of action. Aborting...  "${X}
		exit 1
	fi
fi

#if the branch is not on the remote, allow them to create it
if [ ! $checkoutremote ]; then
	declare -a choices
	choices[0]="Create branch ${STYLE_NEWBRANCH}\`${1}\`${STYLE_MENU_OPTION} from ${STYLE_OLDBRANCH_H1}\`${startingBranch}\`"${X}
	choices[1]="Create branch ${STYLE_NEWBRANCH}\`${1}\`${STYLE_MENU_OPTION} from the current branch ${STYLE_OLDBRANCH_H1}\`${currentBranch}\`"${X}
	if [ "$startingBranch" != "master" ]; then
		choices[2]="Create branch ${STYLE_NEWBRANCH}\`${1}\`${STYLE_MENU_OPTION} from ${STYLE_OLDBRANCH_H1}\`master\`"${X}
	fi

	if __menu "${choices[@]}"; then
		echo ${X}

		# handle decision cases
		case $_menu_sel_index in

			# create new branch from specified branch
			1)
				#nothing to do here since startingBranch is already at the correct value
			;;

			# create new branch from whatever branch user is currently on
			2)
				startingBranch="$currentBranch"
			;;

			#create the branch from master
			3)
				startingBranch="master"
			;;

			# abort process
			*)
				echo "Aborting creation of ${B}\`$1\`${X}..."
				exit 0;;

		esac
	else
		echo ${E}"  Unable to determine a course of action. Aborting...  "${X}
		exit 1
	fi
fi

echo "Base new branch off of ${B}\`${startingBranch}\`${X}"


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
elif [ $checkoutremote ]; then
	echo
	echo
	echo "This checks out the remote ${B}\`${startingBranch}\`${X} to create a new local branch named ${B}\`$1\`${X}"
	echo ${O}${H2HL}
	echo "$ git checkout -b ${1} ${startingBranch}"
	git checkout -b $1 $startingBranch
	echo ${O}${H2HL}${X}
else
	echo
	echo
	echo "You are about to ${A}checkout${X} branch ${B}\`${startingBranch}\`${X} in order to create a new"
	echo "branch named ${B}\`$1\`${X}. Do not do this unless you truly know what you are doing, and why!"
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
		echo 'You have chosen...wisely. Exiting script...'
		exit 0
	fi
fi


#set up tracking for when the branch later gets pushed
git config branch.$1.remote $_remote
git config branch.$1.merge refs/heads/$1


# do this later in the push.sh script. Leaving here in case
# we want a flag that you can set in your config that auto-pushes
# new branches...

# if a remote exists, push to it.
if [ -n "$_remote" ] && [ "$autopushnewbranch" = "true" ]; then
	echo
	echo
	echo "Finally, your new branch will be pushed up to the remote: ${COL_GREEN}${_remote}${COL_NORM}"
	echo ${O}${H2HL}
	echo "$ git push ${_remote} ${1}"
	git push "$_remote" "$1"
	echo ${O}${H2HL}${X}
fi

exit
