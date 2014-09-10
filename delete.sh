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

forceDelete=false
deletePhrase="Deleting branch"

if (( numArgs > 0 && numArgs < 4 )); then
	until [ -z "$1" ]; do

		echo "Param is currently: ${1}"
		echo "Admin?: ${ADMIN}"

		[ "$1" = "--admin" -o "$1" = "-a" -o "$1" = "-A" ] && [ "$ADMIN" = "true" ] && isAdmin=true
		[ "$1" = "--force" -o "$1" = "-f" -o "$1" = "-F" ] && [ "$ADMIN" = "true" ] && forceDelete=true

		# catch multiple flags
		[ "$1" = "-fa" -o "$1" = "-af" -o "$1" = "-AF" -o "$1" = "-FA" ] && [ "$ADMIN" = "true" ] && forceDelete=true && isAdmin=true

		[ "$1" != "--admin" -a "$1" != "-A"  -a "$1" != "-a" -a "$1" != "--force" -a "$1" != "-F" -a "$1" != "-f" -a "$1" != "-fa" -a "$1" != "-af" -a "$1" != "-AF" -a "$1" != "-FA" ] && deleteBranch="$1"
		# [ "$1" != "--admin" -a "$1" != "-A"  -a "$1" != "-a" -a "$1" != "--force" -a "$1" != "-F" -a "$1" != "-f" -a "$1" != "-fa" -a "$1" != "-af" -a "$1" != "-AF" -a "$1" != "-FA" ] && [ "$ADMIN" = "true" ] && deleteBranch="$1"

		shift
	done
fi


# echo "We would force delete: ${forceDelete}"

# make sure branch name was included
if [ -z "$deleteBranch" ]; then
	__bad_usage delete "Branch name to delete is required as the only parameter."
	exit 1
else
	__branch_exists_local "$deleteBranch" && isLocal=true
	__set_remote && __branch_exists_remote "$deleteBranch" && isRemote=true
	[ ! $isLocal ] && [ ! $isAdmin ] && {
		echo ${E}"  The branch \`${deleteBranch}\` does not exist locally! Aborting...  "${X}
		exit 1
	}
fi

if [ $forceDelete == false ]; then
	# give the user a chance to cancel
	echo ${Q}"Are you sure you want to ${A}delete${Q} branch ${B}\`${deleteBranch}\`${Q}? y (n)"${X}
	read yn
	echo
	if [ "$yn" != "y" ] && [ "$yn" != "Y" ]; then
		echo "You got it. Aborting ${A}delete${X}..."
		exit 1
	fi
fi

if [ $forceDelete == true ]; then
	deletePhrase="Force deleting branch"
fi

echo
echo ${H1}${H1HL}
echo "  ${deletePhrase}: ${H1B}\`${deleteBranch}\`${H1}  "
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
		if [ $forceDelete == false ]; then
			echo ${W}"Your local copy of this \`${deleteBranch}\` is behind the remote."
			echo "Continue anyways? (y) n"${X}
			read yn
			if [ -n "$yn" ] && { [ "$yn" != "y" ] || [ "$yn" != "Y" ]; }; then
				echo
				echo "Aborting delete of ${B}\`${deleteBranch}\`"${X}
				exit 1
			fi
		else
			if ! git branch -D $deleteBranch; then
				echo ${E}"  Force delete failed! Exiting... "${X}
				exit 1
			else
				echo ${COL_GREEN}"Force delete succeeded!"${X}
				echo
				echo "Exiting..."
				exit 0
			fi
		fi
	fi

	if ! git branch -d "$deleteBranch" > /dev/null; then

		if [ $forceDelete == false ]; then
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
			elif [ ! $isAdmin ]; then
				echo "Exiting..."
				exit 0
			fi
		else
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

else
	[ ! $isAdmin ] && echo ${E}"  Branch does not exist locally. Skipping delete...  "${X}
fi

if [ $isAdmin ]; then
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
fi

exit
