#!/bin/bash
# checkout
# checks out a git branch + bunches more!
$loadfuncs


# If no branch name is provided as the first parameter, a list of branches from the
# user's local repository are shown, giving them a choice of which to checkout. Users may
# also view remote branches as well.
if [ -z "$1" ] || [ "$1" = " " ]; then
	echo
	echo ${H2}${H1HL}
	echo "WARNING: Checkout requires a branch name                                            "
	echo ${H1HL}${X}

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
		echo ${I}${H2HL}
		echo "Choose a remote branch (or just hit enter to abort):"
		read decision2
		echo ${H2HL}${X}
		chosenBranchName2=${remotebranches[$decision2]}
		chosenBranchName2=${chosenBranchName2/#fl\//}
		chosenbranchexists2=`git branch -r | grep "${remotebranches[$decision2]}"`

		if [ -z "$decision2" ] || [ "$decision2" = "" ] ; then
			echo ${E}${H1HL}
			echo "ABORTING: checkout requires a branch name to continue                               "
			echo ${H1HL}${X}
			echo
			exit 0
		fi

		if [ -n "$chosenbranchexists2" ] ; then
			echo ${H2}"You chose: ${COL_CYAN}${chosenBranchName2}"${X}
			echo
			eval "${gitscripts_path}checkout.sh ${chosenBranchName2}"
		fi
	elif [ -n "$chosenbranchexists" ] ; then
		echo ${H2}"You chose: ${COL_CYAN}${branches[$decision]}"${X}
		echo
		eval "${gitscripts_path}checkout.sh ${branches[$decision]}"

	else
		echo ${E}"You chose: ${COL_CYAN}${branches[${decision}]}${E}"
		echo "Not sure what to do, as that does not appear to be a valid branch. Aborting."
		echo ${X}
	fi

	echo ${X}
	exit -1
fi


# If the user made it this far, they have passed the branch name as the first parameter to
# the script. Additional processing occurs.
echo ${H1}
echo ${H1HL}
echo "Checking out branch: ${COL_CYAN}$1${H1}"
echo ${H1HL}
echo ${X}
echo

# make sure branch exists
if { __branch_exists "$1"; } then

	# check that the branch is not a protected branch (meaning, one you should always
	# delete to protect against forced updates) by looking for the optional nomerge*
	# paths set by the user.
	branchprotected=""
	if [ -s "${protectmergefrom_path}" ]; then mpaths="${protectmergefrom_path} "; fi
	if [ -s "${protectmergeto_path}" ]; then mpaths="${mpaths}${protectmergeto_path}"; fi
	if [ -n "${mpaths}" ]; then
		branchprotected=`grep "$1" ${mpaths}`
	fi

	if [ -n "$branchprotected" ]; then
		echo ${Q}"Would you like to delete your local copy of ${COL_CYAN}$1${X}${Q} and pull"
		echo ${Q}"down the newest version to protect against forced updates? (y) n"${X}
		read deletelocal
		if [ -z "$deletelocal" ] || [ "$decision" == "y" ] || [ "$decision" == "Y" ]; then
			trydelete=`git branch -d $1 2>&1 | grep "error"`
			if [ -n "$trydelete" ]; then
				echo ${E}"Delete failed!"${X}
				echo ${E}"$trydelete"${X}
				echo
				echo ${Q}"Force delete? y (n)"${X}
				read forcedelete
				if [ "$forcedelete" == "y" ] || [ "$forcedelete" == "Y" ]; then
					trydelete=`git branch -D $1 2>&1 | grep "error"`
					if [ -n "$trydelete" ]; then
						echo
						echo ${E}"Force delete failed!"${X}
						echo ${E}"$trydelete"${X}
						echo
						echo ${Q}"Continue anyways? y (n)"${X}
						read continueanyways
						if [ -z "$continueanyways" ] || [ "$continueanyways" = "n" ] || [ "$continueanyways" = "N" ]; then
							return -1
						fi
					else
						echo
						echo ${COL_GREEN}"Force delete succeeded!"${X}
						echo
					fi
				else
					echo
					echo ${Q}"Continue checking out ${COL_CYAN}$1${COL_NORM}? y (n)"${X}
					read continueanyways
					if [ -z "$continueanyways" ] || [ "$continueanyways" = "n" ] || [ "$continueanyways" = "N" ]; then
						return -1
					fi
				fi
			else
				echo
				echo ${COL_GREEN}"Delete succeeded!"${X}
				echo
			fi
		else
			echo
			echo "Keeping your local copy of ${COL_CYAN}$1${COL_NORM} ..."
			echo
		fi
	fi
fi

# check for "dirty" working directory and provide options if that is the case.
echo
if { ! __parse_git_status clean; }; then
	echo
	echo ${O}${H2HL}
	echo "$ git status"
	git status
	echo ${H2HL}${X}
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

	# 1) Abort
	if [ -z "$decision" ] || [ $decision -eq 1 ]; then
		echo "Aborting checkout."
		echo
		exit -1

	# 2) Commit changes and continue
	elif [ $decision -eq 2 ]; then
		echo ${Q}"Please enter a commit message: "${X}
		read commitmessage
		${gitscripts_path}commit.sh "$commitmessage" -a

	# 3) Stash changes and continue
	elif [ $decision -eq 3 ]; then
		echo "This stashes any local changes you might have made and forgot to commit."
		echo "To access these changes at a later time you can choose between the following:"
		echo "- reapply these changes to a ${STYLE_BRIGHT}new${STYLE_NORM} branch using: ${COL_CYAN}git stash branch <branch_name>"${COL_NORM}
		echo "- OR apply these changes to any branch you are currently on using: ${COL_CYAN}git stash apply"${COL_NORM}
		echo ${O}${H2HL}
		echo "$ git stash"
		git stash
		echo
		echo
		echo "$ git status"
		git status
		echo ${H2HL}${X}
		echo

	# 4) Reset changes to tracked files and continue
	elif [ $decision -eq 4 ]; then
		echo "This attempts to reset your current branch to it's last stable hash, usually HEAD."
		echo "If you have made changes to untracked files, they will be unaffected."
		echo ${O}${H2HL}
		echo "$ git reset --hard"
		git reset --hard
		echo
		echo
		echo "$ git status"
		git status
		echo ${H2HL}${X}
		echo

	# 5) Clean (delete) untracked files and continue
	elif [ $decision -eq 5 ]; then
		echo "This attempts to clean your current branch of all untracked files by deleting them."
		echo ${O}${H2HL}
		echo "$ git clean -f"
		git clean -f
		echo
		echo
		echo "$ git status"
		git status
		echo ${H2HL}${X}
		echo

	# 6) Reset, clean, and continue
	elif [ $decision -eq 6 ]; then
		echo "This attempts to reset your current branch to the last stable commit (HEAD)"
		echo "and attempts to clean your current branch of all untracked files."
		echo ${H2HL}${O}
		echo "$ git reset --hard"
		git reset --hard
		echo
		echo
		echo "$ git clean -f"
		git clean -f
		echo
		echo
		echo "$ git status"
		git status
		echo ${H2HL}${X}
		echo

	# 7) Ignore warning and continue
	elif [ $decision -eq 7 ]; then
		echo "Continuing..."
	else
		exit 1
	fi
else
	echo "Working directory is ${COL_GREEN}clean${COL_NORM}."
	echo
	echo
fi
# END - uncommitted changes/untracked files


# Get up-to-date info from the remote
echo "This tells your local git about all changes on remote"
echo ${O}${H2HL}
echo "$ git fetch --all --prune"
git fetch --all --prune
echo ${H2HL}${X}
echo
echo


# Test checkout of branch. Then checkout the chosen branch if possible.
echo "This checks out the ${COL_CYAN}$1${COL_NORM} branch."
echo ${O}${H2HL}
echo "$ git checkout $1"

# Get updated changes from the remote (there should rarely be any for personal branches)
#TODO: Update this to use our remote choosing function (maybe?)
remote=$(git remote)
onremote=`git branch -r | grep "$1"`

trycheckout=`git checkout $1 2>&1 | grep "error: "`
if [ -n "$trycheckout" ]; then
	nolocal=`git checkout $1 2>&1 | grep "error: pathspec "`
	if [ -n "$nolocal" ]; then
		echo "No local version of $1, attempting to create new local from remote"

		git branch -a | grep "$1"
		remotes_string=$(git branch -a | grep "$1");
		c=0;

		for remote in $remotes_string; 
		do 
		#echo "$c: $remote";
		remotes[$c]=$remote;
		c=$((c+1));
		done

		if [ ${#remotes[@]} -gt 1 ]
			then
			echo ${O}"------------------------------------------------------------------------------------"
			echo "Choose a remote (or just hit enter to abort):"
			echo "------------------------------------------------------------------------------------"
			for (( i = 0 ; i < ${#remotes[@]} ; i++ ))
				do
				remote=$(echo ${remotes[$i]} | sed 's/[a-zA-Z0-9\-]+(\/\{1\}[a-zA-Z0-9\-]+)//p' | sed 's/fl\///' | sed 's/remotes\///')

				if [ $i -le "9" ] ; then
					index="  "$i
				elif [ $i -le "99" ] ; then
					index=" "$i
				else
					index=$i
				fi
				echo "$index: $remote"
			done
			echo ${I}"Choose a remote (or just hit enter to abort):"
			read remote
			echo ${X}

			remote=$(echo ${remotes[$remote]} | sed 's/remotes\// /')
		fi

		echo""
		echo "  Checkout ${remote}? y (n)"
		read YorN
		if [ "$YorN" = "y" ]
			then
			noremote=`git checkout -b $1 ${remote} 2>&1 | grep "error: "`
			if [ -n "$noremote" ]; then
				echo
				echo ${X}${E}"Checkout failed!"
				echo "$noremote"${X}
				echo ${O}${H2HL}${X}
				echo
				echo
				exit -1
			else
				git checkout -b "$1" "${remote}"
			fi
		else
			echo "Aborting"
			exit -1
		fi


	else
		echo
		echo ${X}${E}"Checkout failed!"
		echo "$trycheckout"${X}
		echo ${O}${H2HL}${X}
		echo
		echo
		exit -1
	fi
else
	echo "Already on branch $1"

	# Get updated changes from the remote (there should rarely be any for personal branches)
	remote=$(__get_remote)
	onremote=`git branch -r | grep "$1"`

	if [ -n "$onremote" ]; then
		echo ${H2HL}${X}
		echo
		echo
		echo "Get updated branch changes from ${COL_CYAN}${remote}${COL_NORM}, if any."
		echo ${O}${H2HL}
		echo "$ git pull ${remote} $1"
		git pull $remote $1
	fi
fi


if [ "$1" == "master" ]; then
	# do nothing, already on master
	# echo ${H2HL}${X}
	echo
	echo
else
	# if checkout branch is on the remote, MERGE master in...
	echo ${H2HL}${X}
	echo
	echo
	if [ -n "$onremote" ]; then
		echo ${Q}"${COL_MAG}Merge${COL_NORM} branch ${COL_CYAN}master${COL_NORM} into ${COL_CYAN}$1${COL_NORM}? (y) n"${X}
		read decision

		if [ -z "$decision" ] || [ "$decision" = "y" ] || [ "$decision" = "Y" ]; then
			echo
			echo "Merging ${COL_CYAN}${remote}/master${COL_NORM} into ${COL_CYAN}$1${COL_NORM} ..."
			echo ${O}${H2HL}
			echo "$ git merge ${remote}/master"
			git merge "${remote}/master"
			echo
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
			echo "Rebasing ${COL_CYAN}$1${COL_NORM} onto ${COL_CYAN}${remote}/master${COL_NORM} ..."
			echo ${O}${H2HL}
			echo "$ git rebase ${remote}/master"
			git rebase "${remote}/master"
			echo
			echo
		else
			echo
			echo ${O}${H2HL}
		fi
	fi

fi


# Show status for informational purposes
echo "$ git status"
git status
echo ${H2HL}${X}
echo
