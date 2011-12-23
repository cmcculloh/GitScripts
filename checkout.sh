#!/bin/bash
# checkout
# checks out a git branch

echo

if [ -z "$1" ] || [ "$1" = " " ]
	then


	echo ${H2}"####################################################################################"
	echo "WARNING: Checkout requires a branch name                                            "
	echo "####################################################################################"${X}

	echo ${O}"------------------------------------------------------------------------------------"
	echo "Choose a branch (or just hit enter to abort):"
	echo "------------------------------------------------------------------------------------"
	branches=()
	eval "$(git for-each-ref --shell --format='branches+=(%(refname:short))' refs/heads/)"
	#eval "$(git for-each-ref --shell --format='branches+=(%(refname:short))' refs/remotes/)"
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
	echo "------------------------------------------------------------------------------------"
	echo "  R:  View remote branches"
	echo "------------------------------------------------------------------------------------"${X}
	echo ${I}"Choose a branch (or just hit enter to abort):"
	read decision
	echo ${X}
	chosenbranchexists=`git branch | grep "${branches[$decision]}"`
	if [ -z "$decision" ] || [ "$decision" = "" ] ; then
		echo ${E}"####################################################################################"
		echo "ABORTING: checkout requires a branch name to continue                               "
		echo "####################################################################################"
		echo ${X}
		exit 0
	elif [ "$decision" = "r" ] || [ "$decision" = "R" ] ; then
		echo ${O}"------------------------------------------------------------------------------------"
		echo "Choose a remote branch (or just hit enter to abort):"
		echo "------------------------------------------------------------------------------------"			
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
		echo "------------------------------------------------------------------------------------"${X}
		echo ${I}"------------------------------------------------------------------------------------"
		echo "Choose a remote branch (or just hit enter to abort):"
		echo "------------------------------------------------------------------------------------"			
		read decision2
		echo ${X}
		chosenBranchName2=${remotebranches[$decision2]}
		chosenBranchName2=${chosenBranchName2/#fl\//}
		chosenbranchexists2=`git branch -r | grep "${remotebranches[$decision2]}"`

		if [ -z "$decision2" ] || [ "$decision2" = "" ] ; then
			echo ${E}"####################################################################################"
			echo "ABORTING: checkout requires a branch name to continue                               "
			echo "####################################################################################"
			echo ${X}
			exit 0
		fi

		if [ -n "$chosenbranchexists2" ] ; then
			echo ${h2}"You chose: ${COL_CYAN}${chosenBranchName2}${h2}"
			echo ${X}
			eval "${gitscripts_path}checkout.sh ${chosenBranchName2}"
		fi
	elif [ -n "$chosenbranchexists" ] ; then
		echo ${h2}"You chose: ${COL_CYAN}${branches[$decision]}${h2}"
		echo ${X}
		eval "${gitscripts_path}checkout.sh ${branches[$decision]}"

	else
		echo ${E}"You chose: ${COL_CYAN}${branches[$decision]}${E}"
		echo "Not sure what to do, as that does not appear to be a valid branch. Aborting."
		echo ${X}
	fi
		

	echo ${X}
	exit -1
fi



echo "##########################################"
echo "Checking out branch ${COL_CYAN}$1${COL_NORM}"
echo "##########################################"
echo
echo
echo

#make sure branch exists
branchexists=`git branch | grep "$1"`
if [ -n "$branchexists" ]
	then

	#make sure the branch is not a protected branch (meaning, one you should always delete to protect against forced updates)
	branchprotected=`grep "$1" ${gitscripts_path}../protected_branches_nomergefrom ${gitscripts_path}../protected_branches_nomergeto`
	if [ -n "$branchprotected" ]
		then
		echo "delete your local copy of $1,"
		echo "and pull down new version to protect against forced updates? (y) n"
		read deletelocal
		if [ -z "$deletelocal" ] || [ "$decision" = "y" ]
			then
			trydelete=`git branch -d $1 2>&1 | grep "error"`
			echo "$trydelete"
			echo
			if [ -n "$trydelete" ]
				then
				echo "Delete failed!"
				echo "force delete? y (n)"
				read forcedelete
				if [ "$forcedelete" = "y" ]
					then
					trydelete=`git branch -D $1 2>&1 | grep "error"`
					echo "$trydelete"
					echo
					if [ -n "$trydelete" ]
						then
						echo "force delete failed! continue anyways? y (n)"
						read continueanyways
						if [ -z "$continueanyways" ] || [ "$continueanyways" = "n" ]
							then
							return -1
						fi
					else
						echo "force delete succeeded!"
					fi
				else
					echo "continue checking out ${COL_CYAN}$1${COL_NORM}? y (n)"
					read continueanyways
					if [ -z "$continueanyways" ] || [ "$continueanyways" = "n" ]
						then
						return -1
					fi
				fi
			else
				echo "delete succeeded!"
				echo
			fi
		else
			echo "not deleteing your local copy of ${COL_CYAN}$1${COL_NORM}"
			echo
		fi
	fi
fi

echo
echo
checkbranch=`git status | grep "nothing to commit (working directory clean)"`
echo "$checkbranch"

if [ -z "$checkbranch" ]
	then
	echo
	echo "git status"
	git status
	echo
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
	echo You chose: $decision
	echo
	if [ -z "$decision" ] || [ $decision -eq 1 ]
		then
		echo "Aborting checkout."
		echo
		return -1
	elif [ -z "$decision" ] || [ $decision -eq 7 ]
		then
		echo continuing...
	elif [ $decision -eq 2 ]
		then
		echo "please enter a commit message"
		read commitmessage
		${gitscripts_path}commit.sh "$commitmessage" -a
	elif [ $decision -eq 3 ]
		then
		echo This stashes any local changes you might have made and forgot to commit
		echo git stash
		git stash
		echo
		echo

		echo git status
		git status
		echo
		echo
	elif [ $decision -eq 4 ]
		then
		echo This attempts to reset your current branch to the last checkin
		echo if you have made changes to untracked files, this will not affect those
		echo git reset --hard
		git reset --hard
		echo
		echo

		echo git status
		git status
		echo
		echo
	elif [ $decision -eq 5 ]
		then
		echo This attempts to clean your current branch of all untracked files
		echo git clean -f
		git clean -f
		echo
		echo

		echo git status
		git status
		echo
		echo
	elif [ $decision -eq 6 ]
		then
		echo This attempts to reset your current branch to the last checkin
		echo and attempts to clean your current branch of all untracked files
		echo git reset --hard
		git reset --hard
		echo
		echo
		echo git clean -f
		git clean -f
		echo
		echo
		echo git status
		git status
		echo
		echo
	else
		return 1
	fi
fi

echo "This tells your local git about all changes on remote"
echo "git fetch --all --prune"
git fetch --all --prune
echo
echo



echo "This checks out the ${COL_CYAN}$1${COL_NORM} branch"
echo "git checkout $1"
git checkout $1
trycheckout=`git checkout $1 2>&1 | grep "error: "`
echo
if [ -n "$trycheckout" ]
	then
	echo "Checkout failed!"
	return -1
fi


remote=$(git remote)
onremote=`git branch -r | grep "$1"`

if [ -n "$onremote" ]
	then
	echo "git pull $remote $1"
	git pull $remote $1
fi

echo
echo
echo git status
git status
echo
echo

if [ $1 = "master" ]
	then
	#do nothing, already on master
	echo
else
	if [ -n "$onremote" ]
		then
		echo "merge master into ${COL_CYAN}$1${COL_NORM}? (y) n"
		read decision

		if [ -z "$decision" ] || [ "$decision" = "y" ]
			then
			echo
			echo "Merging $remote/master into ${COL_CYAN}$1${COL_NORM}"
			echo
			echo "git merge $remote/master"
			git merge $remote/master
		fi
	else
		echo "rebase ${COL_CYAN}$1${COL_NORM} onto master? (y) n"
		read decision
		if [ -z "$decision" ] || [ "$decision" = "y" ]
			then
			echo
			echo "Rebasing ${COL_CYAN}$1${COL_NORM} onto $remote/master"
			echo
			echo "git rebase $remote/master"
			git rebase $remote/master
		fi
	fi

	echo
	echo
	echo git status
	git status
	echo
	echo
fi