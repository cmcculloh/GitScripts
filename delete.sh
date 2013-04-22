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
#	@dependencies
#	*checkout.sh
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
		deleteBranch="$1"
		shift
	done
fi

# make sure branch name was included
if [ -z "$deleteBranch" ]; then
	__bad_usage delete "Branch name to delete is required as the only parameter."
	exit 1
else
	__branch_exists_local "$deleteBranch" && isLocal=true
	__set_remote && __branch_exists_remote "$deleteBranch" && isRemote=true
fi

# give the user a chance to cancel
echo ${Q}"Are you sure you want to ${A}delete${Q} branch ${B}\`${deleteBranch}\`${Q}? y (n)"${X}
read yn
echo
if [ "$yn" != "y" ] && [ "$yn" != "Y" ]; then
	echo "You got it. Aborting ${A}delete${X}..."
	exit 1
fi

echo
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

	# create choices. third choice only available if a remote is configured.
	declare -a choices
	choices=( "Checkout branch \`master\`" "Checkout a local branch" )
	[ $isRemote ] && choices[2]="Checkout a remote branch"

	if __menu "${choices[@]}"; then

		# This case will not get executed unless the menu selection is valid.
		checkoutBranch=
		case $_menu_sel_index in
			# checkout master
			1)
				checkoutBranch="master";;

			# checkout a local branch
			2)
				echo
				echo "Loading local branches..."
				__get_branch -l && checkoutBranch=$_branch_selection || {
					echo
					echo ${E}"  No branch chosen to switch to. Aborting...  "${X}
					exit 1
				};;

			# checkout a remote branch (if remote is configured)
			3)
				echo
				echo "  Loading remote branches..."
				__get_branch -r && checkoutBranch=$(echo $_branch_selection | sed "s/${_remote}\\//") || {
					echo
					echo ${E}"  No branch chosen to switch to. Aborting...  "${X}
					exit 1
				};;

			*)
				echo "  Now exiting...  ";
				exit 0
				;;
		esac
		echo "Branch selected: $checkoutBranch"
		exit
		echo
		"${gitscripts_path}"checkout.sh $checkoutBranch
		echo
		echo

	else
		echo
		echo ${E}"  Your selection could not be interpreted. Exiting...  "${X}
		exit 1
	fi

fi # END if current branch is the same as branch to delete


if [ $isLocal ]; then

	#Determine if your local copy is behind remote
	if [ $isRemote ] && git branch -v --abbrev=7 | egrep -q "$deleteBranch.*\[behind\ [0-9]*\]"; then
		echo ${W}"Your local copy of this \`${deleteBranch}\` is behind the remote."
		echo "Continue anyways? (y) n"${X}
		read yn
		if [ -n "$yn" ] && { [ "$yn" != "y" ] || [ "$yn" != "Y" ]; }; then
			echo
			echo "Aborting delete of ${B}\`${deleteBranch}\`"${X}
			exit 1
		fi
	fi

	if ! git branch -d "$deleteBranch" > /dev/null; then
		echo ${W}"Delete failed! Would you like to force-delete the branch?  y (n)"${X}
		read yn
		echo
		if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
			if ! git branch -D $deleteBranch; then
				echo ${E}"  Force delete failed! Exiting... "${X}
				exit 1
			else
				echo ${COL_GREEN}"Force delete succeeded!"${X}
				echo
			fi
		fi
	else
		echo ${COL_GREEN}"Delete succeeded!"${X}
		echo
	fi
fi

if [ $isRemote ]; then
	echo
	echo ${Q}"Delete ${B}\`${_remote}/${deleteBranch}\`${Q}? y (n)"${X}
	read yn
	echo

	if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then

		if __is_branch_protected --all "$deleteBranch"; then
			echo ${W}"WARNING: \`${deleteBranch}\` is a protected branch."
			echo "Are you SURE you want to delete the remote copy? yes (n)${X}"${X}
			read yn
			if [ -z "$yn" ] || [ "$yn" != "yes" ]; then
				echo "Aborting delete of remote branch..."
				exit 1
			fi
		fi

		echo
		echo "Deleting ${B}\`${_remote}/${deleteBranch}\`${X} ..."
		echo ${O}${H2HL}
		echo "$ git push ${remote} :${deleteBranch}"
		git push "$remote" :"$deleteBranch"
		echo ${H2HL}${X}
	else
		echo "Delete aborted. Exiting..."
		exit 1
	fi
else
	echo "Branch \`${deleteBranch}\` is not on a remote. Now exiting..."
	exit 1
fi

exit
