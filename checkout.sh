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
#	functions/0300.menu.sh
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
# also view remote branches if desired.
if [ -z "$1" ]; then
	echo ${W}"WARNING: Checkout requires a branch name                                            "${X}
	echo

	if ! __get_branch -l; then
		echo
		echo ${E}"  No branch chosen. Aborting...  "${X}
		exit 1
	else
		"${gitscripts_path}"checkout.sh "$_branch_selection"
		exit
	fi
fi

# set the branch that the script will be using
patt="[^/]*\/"
branch=${1/$patt/}

# If the user made it this far, they have passed the branch name as the first parameter to
# the script. Additional processing occurs. Begin by establishing where the branch exists.
onremote=
onlocal=
__branch_exists_remote "$branch" && onremote=true
__branch_exists_local "$branch" && onlocal=true

# Don't try checking out a branch you are already on...
cb=$(__parse_git_branch)
if [ "$cb" = "$branch" ]; then
	echo ${E}"  You are already on branch \`${branch}\`! Aborting...  "${X}
	exit 1
elif [ ! $onlocal ] && [ ! $onremote ]; then
	# ...and hopefully the branch exists SOMEWHERE.
	"${gitscripts_path}"branch.sh "$branch"
	exit
fi


echo
echo ${H1}${H1HL}
echo "Checking out branch: ${H1B}\`${branch}\`${H1}  "
echo ${H1HL}${X}
echo
echo

# make sure branch exists
if __branch_exists "$branch"; then

	# check that the branch is not a protected branch (meaning, one you should always
	# delete to protect against forced updates) by looking for the optional nomerge*
	# paths set by the user.
	if __is_branch_protected --merge "$branch" && [ $onlocal ]; then
		echo ${Q}"Would you like to ${A}delete${Q} your local copy of ${B}\`${branch}\`${Q} and ${A}pull${Q}"
		echo "down the newest version to protect against forced updates? (y) n"${X}
		read deletelocal
		if [ -z "$deletelocal" ] || [ "$decision" == "y" ] || [ "$decision" == "Y" ]; then
			trydelete=`git branch -d "$branch" 2>&1 | grep "error"`
			if [ -n "$trydelete" ]; then
				echo ${E}"Delete failed!"
				echo "$trydelete"${X}
				echo
				echo ${Q}"Force ${A}delete${Q} ${B}\`${branch}\`${Q}? y (n)"${X}
				read forcedelete
				if [ "$forcedelete" = "y" ] || [ "$forcedelete" = "Y" ]; then
					trydelete=`git branch -D "$branch" 2>&1 | grep "error"`
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
					echo ${Q}"Continue checking out ${B}\`${branch}\`${Q}? y (n)"${X}
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
			echo "Keeping your local copy of ${B}\`${branch}\`${X} ..."
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
	echo
	echo ${W}"  You appear to have uncommitted changes.  "${X}
	echo
	declare -a choices
	choices[0]="${A}Commit${STYLE_MENU_OPTION} changes and continue with checkout of \`${B}${branch}\`"${X}
	choices[1]="${A}Stash${STYLE_MENU_OPTION} Changes and continue with checkout of \`${B}${branch}\`"${X}
	choices[2]="${A}Reset${STYLE_MENU_OPTION} (revert) all changes to tracked files (ignores untracked files), and continue with checkout of \`${B}${branch}\`"${X}
	choices[3]="${A}Clean${STYLE_MENU_OPTION} (delete) untracked files, and continue with checkout of \`${B}${branch}\`"${X}
	choices[4]="${A}Reset & Clean${STYLE_MENU_OPTION} (revert & delete) all changes, and continue with checkout of \`${B}${branch}\`"${X}
	choices[5]="I know what I'm doing, continue with checkout of \`${B}${branch}\`"${X}

	if __menu "${choices[@]}"; then
		echo ${X}
		case $_menu_sel_index in
			# Commit changes and continue
			1)
				echo ${I}"Please enter a commit message: "${X}
				read commitmessage
				"${gitscripts_path}"commit.sh "$commitmessage" -a;;

			# Stash changes and continue
			2)
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
			3)
				echo "This attempts to ${A}reset${X} your current branch to it's last stable hash, usually HEAD."
				echo "If you have made changes to untracked files, they will NOT be affected."
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
			4)
				echo "This attempts to ${A}clean${X} ${B}\`${branch}\`${X} of all untracked files by deleting them."
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
			5)
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
			6)
				echo "Continuing..."
				echo;;

			# User aborted
			*)
				echo "Exiting..."
				exit 0;;
		esac
	else
		echo
		echo ${E}"  Unable to determine branch to checkout. Aborting...  "${X}
		exit 1
	fi

else
	echo "Working directory is ${COL_GREEN}clean${COL_NORM}."
	echo
fi
# END - uncommitted changes/untracked files


# Configure the remote if one or more exists
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
echo "This checks out the ${B}\`${branch}\`${X} branch."
echo ${O}${H2HL}${X}
if __branch_exists_local $branch; then
	echo ${O}"$ git checkout $branch"
	git checkout "$branch"
	echo ${O}${H2HL}${X}
else
	${gitscripts_path}new.sh "$branch" from "${_remote}/$branch" --no-questions
fi


# Get updated changes from the remote (there should rarely be any for personal branches)
if [ $onremote ]; then
	echo
	echo
	echo "Get updated branch changes from ${COL_GREEN}${_remote}${COL_NORM}, if any."
	echo ${O}${H2HL}
	echo "$ git pull ${_remote} ${branch}"
	git pull "$_remote" "$branch"
	echo ${O}${H2HL}${X}
fi

# MERGE master into branch to keep it up to date
echo
echo
if [ "$branch" != "master" ]; then
	if [ $onremote ]; then
		__merge_master

	# ...otherwise rebase this branch's changes onto master ("cleaner" option)
	else
		echo ${Q}"${A}Rebase${Q} branch ${B}\`${branch}\`${Q} onto \`${B}master${Q}? (y) n"${X}
		read decision

		if [ -z "$decision" ] || [ "$decision" = "y" ] || [ "$decision" = "y" ]; then
			echo
			echo "${A}Rebasing${X} ${B}\`${branch}\`${X} onto ${B}\`${remote}/master\`${X} ..."
			echo ${O}${H2HL}
			echo "$ git rebase ${remote}/master"
			git rebase "${remote}/master"
			echo ${O}
			echo
		else
			echo
			echo ${O}${H2HL}
			__merge_master
		fi
	fi
fi # END if [ "$branch" != "master" ]


# Show status for informational purposes
echo "$ git status"
git status
echo ${O}${H2HL}${X}


exit
