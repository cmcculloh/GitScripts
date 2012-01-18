#!/bin/bash
## /*
#	@usage checkout [branch-name]
#
#	@description
#	This script assists with checking out a branch in several ways. Firstly, if you
#	don't know the specific name of the branch for whatever reason, you can omit the
#	branch name as the first parameter to view a list of all branches, even branches
#	on the remote, if any. Secondly, You are automatically prompted to merge master into
#	the branch which you are checking out to keep it current. In addition, safeguards
#	are in place to prevent unnecessary processing if, for instance, you are already
#	on the branch you are trying to checkout or the branch doesn't exist locally,
#	remotely, or at all.
#	description@
#
#
#	@examples
#	1) checkout
#	   # Will show a list of branches available for checkout.
#	2) checkout my-big-project-changes
#	   # checks out my-big-project-changes and will attempt to merge master into it
#	   # or rebase it onto master.
#	examples@
#
#	@dependencies
#	functions/5000.branch_exists_remote.sh
#	functions/5000.branch_exists_local.sh
#	functions/5000.parse_git_branch.sh
#	functions/5000.parse_git_status.sh
#	functions/5000.set_remote.sh
#	dependencies@
#
#	@file checkout.sh
## */
$loadfuncs


echo ${X}


# If no branch name is provided as the first parameter, a list of branches from the
# user's local repository are shown, giving them a choice of which to checkout. Users may
# also view remote branches as well.
if [ -z "$1" ]; then
	echo ${W}"WARNING: Checkout requires a branch name                                            "${X}
	echo

	echo ${O}${H2HL}
	echo "Choose a branch (or just hit enter to abort):"
	echo ${H2HL}
	branches=()
	eval "$(git for-each-ref --shell --format='branches+=(%(refname:short))' refs/heads/)"
	for (( i = 0 ; i < ${#branches[@]} ; i++ ))
	do
		if [ $i -le "9" ] ; then
			index="  "$i
		elif [ $i -le "99" ] ; then
			index=" "$i
		else
			index=$i
		fi
		echo "$index: " ${branches[$i]}
		# yadda yadda
	done
	echo ${H2HL}
	echo "  R:  View remote branches"
	echo ${H2HL}${X}
	echo ${I}"Choose a branch (or just hit enter to abort):"${X}
	read decision
	echo
	chosenbranchexists=`git branch | grep "${branches[$decision]}"`
	if [ -z "$decision" ] || [ "$decision" = "" ] ; then
		echo ${E}${H1HL}
		echo "ABORTING: checkout requires a branch name to continue                               "
		echo ${H1HL}${X}
		echo
		exit 0
	elif [ "$decision" = "r" ] || [ "$decision" = "R" ] ; then
		echo ${O}${H2HL}
		echo "Choose a remote branch (or just hit enter to abort):"
		echo ${H2HL}
		remotebranches=()
		eval "$(git for-each-ref --shell --format='remotebranches+=(%(refname:short))' refs/remotes/)"
		for (( i = 0 ; i < ${#remotebranches[@]} ; i++ ))
		do
			if [ $i -le "9" ] ; then
				index="  "$i
			elif [ $i -le "99" ] ; then
				index=" "$i
			else
				index=$i
			fi
			echo "$index: " ${remotebranches[$i]}
		done
		echo ${H2HL}${X}
		echo ${I}"Choose a remote branch (or just hit enter to abort):"${X}
		read decision2
		echo ${O}${H2HL}${X}
		chosenBranchName2=${remotebranches[$decision2]}
		chosenBranchName2=${chosenBranchName2/#fl\//}
		chosenbranchexists2=`git branch -r | grep "${remotebranches[$decision2]}"`

		if [ -z "$decision2" ]; then
			echo ${E}${H1HL}
			echo "ABORTING: checkout requires a branch name to continue                               "
			echo ${H1HL}${X}
			echo
			exit 0
		fi

		if [ -n "$chosenbranchexists2" ] ; then
			echo "You chose: ${B}\`${chosenBranchName2}\`"${X}
			echo
			eval "${gitscripts_path}checkout.sh ${chosenBranchName2}"
		fi
	elif [ -n "$chosenbranchexists" ] ; then
		echo "You chose: ${B}\`${branches[$decision]}\`"${X}
		echo
		eval "${gitscripts_path}checkout.sh ${branches[$decision]}"

	else
		echo ${E}"  You chose: \`${branches[${decision}]}\`"
		echo "  Not sure what to do, as that does not appear to be a valid branch. Aborting...  "${X}
		echo
	fi

	echo ${X}
	exit 1
fi


# If the user made it this far, they have passed the branch name as the first parameter to
# the script. Additional processing occurs. Begin by establishing where the branch exists.
__branch_exists_remote $1 && onremote=true
__branch_exists_local $1 && onlocal=true

# Don't try checking out a branch you are already on...
cb=$(__parse_git_branch)
if [ "$cb" = "$1" ]; then
	echo ${E}"  You are already on branch \`$1\`! Aborting...  "${X}
	exit 1

# ...and hopefully the branch exists SOMEWHERE.
elif [ ! $onlocal ] && [ ! $onremote ]; then
	echo ${E}"  The branch \`$1\` does not exist! Aborting...  "${X}
	exit 1
fi


echo
echo ${H1}${H1HL}
echo "Checking out branch: ${H1B}\`$1\`${H1}  "
echo ${H1HL}${X}
echo
echo

# make sure branch exists
if __branch_exists "$1"; then

	# check that the branch is not a protected branch (meaning, one you should always
	# delete to protect against forced updates) by looking for the optional nomerge*
	# paths set by the user.
	if __is_branch_protected --merge "$1" && [ $onlocal ]; then
		echo ${Q}"Would you like to ${A}delete${Q} your local copy of ${B}\`$1\`${Q} and ${A}pull${Q}"
		echo "down the newest version to protect against forced updates? (y) n"${X}
		read deletelocal
		if [ -z "$deletelocal" ] || [ "$decision" == "y" ] || [ "$decision" == "Y" ]; then
			trydelete=`git branch -d "$1" 2>&1 | grep "error"`
			if [ -n "$trydelete" ]; then
				echo ${E}"Delete failed!"
				echo "$trydelete"${X}
				echo
				echo ${Q}"Force ${A}delete${Q} ${B}\`$1\`${Q}? y (n)"${X}
				read forcedelete
				if [ "$forcedelete" = "y" ] || [ "$forcedelete" = "Y" ]; then
					trydelete=`git branch -D "$1" 2>&1 | grep "error"`
					if [ -n "$trydelete" ]; then
						echo
						echo ${E}"Force delete failed!"
						echo "$trydelete"${X}
						echo
						echo ${Q}"Continue anyways? y (n)"${X}
						read continueanyways
						if [ "$continueanyways" != "y" ] && [ "$continueanyways" != "Y" ]; then
							exit
						fi
					else
						echo
						echo ${COL_GREEN}"Force delete succeeded!"${X}
						echo
					fi
				else
					echo
					echo ${Q}"Continue checking out ${B}\`$1\`${Q}? y (n)"${X}
					read continueanyways
					if [ "$continueanyways" != "y" ] && [ "$continueanyways" != "Y" ]; then
						exit
					fi
				fi
			else
				echo
				echo ${COL_GREEN}"Delete succeeded!"${X}
				echo
			fi
		else
			echo
			echo "Keeping your local copy of ${B}\`$1\`${X} ..."
			echo
		fi
	fi
	echo
fi

# check for "dirty" working directory and provide options if that is the case.
if ! __parse_git_status clean; then
	echo
	echo ${O}${H2HL}
	echo "$ git status"
	git status
	echo ${O}${H2HL}${X}
	echo

	echo "You appear to have uncommited changes."
	echo " (1) -  ${COL_YELLOW}Abort${COL_NORM} checkout of ${COL_CYAN}$1${COL_NORM}"
	echo "  2  -  ${COL_YELLOW}Commit${COL_NORM} changes and continue checkout of ${COL_CYAN}$1${COL_NORM}"
	echo "  3  -  ${COL_YELLOW}Stash${COL_NORM} Changes and continue with checkout of ${COL_CYAN}$1${COL_NORM}"
	echo "  4  -  ${COL_YELLOW}Reset${COL_NORM} (revert) all changes to tracked files (ignores untracked files), and continue with checkout of branch ${COL_CYAN}$1${COL_NORM}"
	echo "  5  -  ${COL_YELLOW}Clean${COL_NORM} (delete) untracked files, and continue with checkout of branch ${COL_CYAN}$1${COL_NORM}"
	echo "  6  -  ${COL_YELLOW}Reset${COL_NORM} & ${COL_YELLOW}Clean${COL_NORM} (revert & delete) all changes, and continue with checkout of branch ${COL_CYAN}$1${COL_NORM}"
	echo "  7  -  I know what I'm doing, continue with checking out ${COL_CYAN}$1${COL_NORM} anyways"
	read decision
	echo "You chose: ${decision}"
	echo

	# will not accept anything other than a numeric choice. default to Abort.
	! echo "$decision" | egrep -q '^[1-7]$' && decision=1

	case $decision in
		#Abort
		1)
			echo "Aborting checkout..."
			echo
			exit 1;;

		# Commit changes and continue
		2)
			echo ${I}"Please enter a commit message: "${X}
			read commitmessage
			"${gitscripts_path}"commit.sh "$commitmessage" -a;;

		# Stash changes and continue
		3)
			echo "This ${A}stashes${X} any local changes you might have made and forgot to commit."
			echo "To access these changes at a later time you can choose between the following:"
			echo "- reapply these changes to a ${STYLE_BRIGHT}new${STYLE_NORM} branch using: ${A}git stash branch <branch_name>"${X}
			echo "- OR apply these changes to any branch you are currently on using: ${A}git stash apply"${X}
			echo ${O}${H2HL}
			echo "$ git stash"
			git stash
			echo ${O}
			echo
			echo "$ git status"
			git status
			echo ${O}${H2HL}${X}
			echo;;

		# Reset changes to tracked files and continue
		4)
			echo "This attempts to ${A}reset${X} your current branch to it's last stable hash, usually HEAD."
			echo "If you have made changes to untracked files, they will be unaffected."
			echo ${O}${H2HL}
			echo "$ git reset --hard"
			git reset --hard
			echo ${O}
			echo
			echo "$ git status"
			git status
			echo ${O}${H2HL}${X}
			echo;;

		# Clean (delete) untracked files and continue
		5)
			echo "This attempts to ${A}clean${X} ${B}\`$1\`${X} of all untracked files by deleting them."
			echo ${O}${H2HL}
			echo "$ git clean -f"
			git clean -f
			echo ${O}
			echo
			echo "$ git status"
			git status
			echo ${O}${H2HL}${X}
			echo;;

		# Reset, clean, and continue
		6)
			echo "This attempts to ${A}reset${X} your current branch to the last stable commit (HEAD)"
			echo "and attempts to ${A}clean${X} your current branch of all untracked files."
			echo ${H2HL}${O}
			echo "$ git reset --hard"
			git reset --hard
			echo ${O}
			echo
			echo "$ git clean -f"
			git clean -f
			echo ${O}
			echo
			echo "$ git status"
			git status
			echo ${O}${H2HL}${X}
			echo;;

		# Ignore warning and continue
		7)
			echo "Continuing..."
			echo;;
	esac

else
	echo "Working directory is ${COL_GREEN}clean${COL_NORM}."
	echo
fi
# END - uncommitted changes/untracked files


# Get updated changes from the remote (there should rarely be any for personal branches)
#TODO: Update this to use our remote choosing function (maybe?)
echo "Configuring remote(s), if any..."
__set_remote
echo

# Get up-to-date info from the remote, if any
if [ $_remote ]; then
	echo
	echo "This tells your local git about all changes on ${COL_GREEN}${_remote}${COL_NORM}..."
	echo ${O}${H2HL}
	echo "$ git fetch --all --prune"
	git fetch --all --prune
	echo ${O}${H2HL}${X}
	echo
	echo
fi


# Checkout the chosen branch if possible.
echo "This checks out the ${B}\`$1\`${X} branch."
echo ${O}${H2HL}
if __branch_exists_local master; then
	echo "$ git checkout $1"
	git checkout "$1"
else
	${gitscripts_path}new.sh "$1"
fi
echo ${O}${H2HL}${X}


# Get updated changes from the remote (there should rarely be any for personal branches)
if [ $onremote ]; then
	echo
	echo
	echo "Get updated branch changes from ${COL_GREEN}${_remote}${COL_NORM}, if any."
	echo ${O}${H2HL}
	echo "$ git pull ${remote} $1"
	git pull $remote $1
	echo ${O}${H2HL}${X}
fi


# MERGE master into branch to keep it up to date
echo
echo
if [ "$1" != "master" ]; then
	if [ $onremote ]; then
		echo ${Q}"${A}Merge${Q} branch ${B}\`master\`${Q} into ${B}\`$1\`${Q}? (y) n"${X}
		read decision

		if [ -z "$decision" ] || [ "$decision" = "y" ] || [ "$decision" = "Y" ]; then
			echo
			echo "${A}Merging${X} ${B}\`${remote}/master\`${X} into ${B}\`$1\`${X} ..."
			echo ${O}${H2HL}
			echo "$ git merge ${remote}/master"
			git merge "${remote}/master"
			echo ${O}
			echo
		else
			echo
			echo ${O}${H2HL}
		fi

	# ...otherwise rebase this branch's changes onto master ("cleaner" option)
	else
		echo ${Q}"${COL_MAG}Rebase${COL_NORM} branch ${COL_CYAN}$1${COL_NORM} onto ${COL_CYAN}master${COL_NORM}? (y) n"${X}
		read decision

		if [ -z "$decision" ] || [ "$decision" = "y" ] || [ "$decision" = "y" ]; then
			echo
			echo "${A}Rebasing${X} ${B}\`$1\`${X} onto ${B}\`${remote}/master\`${X} ..."
			echo ${O}${H2HL}
			echo "$ git rebase ${remote}/master"
			git rebase "${remote}/master"
			echo ${O}
			echo
		else
			echo
			echo ${O}${H2HL}
		fi
	fi
fi # END if [ "$1" != "master" ]


# Show status for informational purposes
echo "$ git status"
git status
echo ${O}${H2HL}${X}


exit
