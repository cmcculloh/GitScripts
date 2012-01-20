#!/bin/bash
## /*
#	@usage delete <branch-name>
#
#	@description
#	This script isa  wrapper for removing branches locally. Removing them locally requires a bit of
#	magic, which can be determined by observing the source code carefully. This obfuscation is
#	included to prevent team members without sufficient access from deleting important remote
#	branches.
#	description@
#
#	@notes
#	-
#	notes@
#
#	@dependencies
#	checkout.sh
#	functions/0100.bad_usage.sh
#	functions/5000.branch_exists_local.sh
#	functions/5000.branch_exists_remote.sh
#	functions/5000.parse_git_branch.sh
#	dependencies@
#
#	@file delete.sh
## */
$loadfuncs


echo ${X}

# parse arguments
numArgs=$#
if (( numArgs > 0 && numArgs < 3 )); then
	until [ -z "$1" ]; do
		if [ "$1" == "--admin" ] && [ $ADMIN ] && isAdmin=true
		! echo "$1" | egrep -q "^-" && deleteBranch="$1"
		shift
	done
fi

# make sure branch name was included
if [ -z "$deleteBranch" ]; then
	__bad_usage delete "Branch name to delete is required as the only parameter."
	exit 1
else
	__branch_exists_local "$deleteBranch" && isLocal=true
	__branch_exists_remote "$deleteBranch" && isRemote=true
	[ ! $isLocal ] && [ ! $isRemote ] && {
		echo ${E}"  The branch \`${deleteBranch}\` exists neither locally or remotely! Aborting...  "${X}
		exit 1
	}
fi


echo ${H1}${H1HL}
echo "  Deleting branch: ${H1B}\`${deleteBranch}\`${H1}  "
echo ${H1HL}${X}
echo
echo

# check to see if already on branch to delete
cb=$(__parse_git_branch)
if [ -n "$cb" ] && [ "$cb" = "$deleteBranch" ]; then
	echo ${W}"  You are currently on branch \`${deleteBranch}\` so it cannot be deleted.  "${X}
	echo
	__menu "Checkout branch \`master\`" "Checkout a different branch"
	# echo "(1) Checkout master"
	# echo "2 Checkout another branch"
	# echo "3 Abort"
	# read choice

	if [ -z "$_menu_selection" ] || [ $choice -eq 1 ]
		then
		echo
		echo "git checkout master"
		${gitscripts_path}checkout.sh master
		echo
		echo
	elif [ $choice -eq 2 ]
		then
		echo "please specify the branch you wish to check out,"
		echo "or enter \"abort\" to quit"
		read enteredBranchName
		if [ "$enteredBranchName" = "abort" ]
			then
			exit 0
		fi
		echo
		echo checking out $enteredBranchName before deleting branch $deleteBranch
		echo
		echo

		${gitscripts_path}checkout.sh $enteredBranchName
	elif [ $choice -eq 3 ]
		then
		exit 0
	fi

	if [ $? -lt 0 ]
		then
		echo
		echo "something went wrong!"
		echo
		echo "git status"
		git status

		exit -1
	fi
fi

if __branch_exists_local $deleteBranch; then


	#Determine if your local copy is behind remote
	isbehind=$(git branch -v --abbrev=7 | grep "$deleteBranch" | grep "\[behind\ [0-9]*\]")
	if [ $behind ]; then
		echo
		echo "${W}Your local copy of this $deleteBranch"
		echo "is behind the remote. Continue anyways? (y) n${X}"
		read yn
		if [ "$yn" != "y" ]; then
			echo "Aborting delete of $deleteBranch"
			exit 1
		fi
	fi

	if ! git branch -d $deleteBranch
		then
		echo ${W}"Delete failed! Would you like to force-delete the branch?  y (n)"${X}
		echo
		read forcedelete
		if [ "$forgo cedelete" = "y" ]
			then
			if ! git branch -D $deleteBranch
				then
				echo "force delete failed!"
				exit -1
			else
				echo "force delete succeeded!"
				echo
			fi
		fi
	else
		echo "Delete succeeded!"
		echo
	fi
else
	echo "Branch does not exist. Skipping delete..."
fi

if [ $isAdmin ]; then
	onremote=`git branch -r | grep "$deleteBranch"`
	if [ -n "$onremote" ]
		then
		echo
		echo "delete remote copy of branch? y (n)"
		read deleteremote

		if [ -n "$deleteremote" ] && [ "$deleteremote" = "y" ]
			then

			__is_branch_protected --all "$deleteremote" && isProtected=true
			if [ $isProtected ]; then
				echo "${W}WARNING: $deleteBranch is a protected branch."
				echo "Are you SURE you want to delete remote copy? yes (n)${X}"
				read yn
				if [ -z "$yn" ] || [ "$yn" != "yes" ]
					then
					echo "aborting delete of remote branch..."
					exit 1
				fi
			fi


			__set_remote
			echo
			echo "deleting $deleteBranch on $_remote!"
			echo
			remote=$_remote
			echo "git push $remote :$deleteBranch"
			git push $remote :$deleteBranch
		fi
	else
		echo "not on remote"
	fi
fi

exit
