#!/bin/bash
# checkout
# checks out a git branch
echo "##########################################"
echo Checking out branch $1
echo "##########################################"
echo
echo

if [ -z "$1" ] || [ "$1" = " " ]
	then
	echo "Please specify a branch to check out"
	git branch
	exit -1
fi


branchexists=`git branch | grep "$1"`

if [ -n "$branchexists" ]
	then
	if [ "$1" = "dev" ] || [ $1 = "qa" ]
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
							exit -1
						fi
					else
						echo "force delete succeeded!"
					fi
				else
					echo "continue checking out $1? y (n)"
					read continueanyways
					if [ -z "$continueanyways" ] || [ "$continueanyways" = "n" ]
						then
						exit -1
					fi
				fi
			else
				echo "delete succeeded!"
				echo
			fi
		else
			echo "not deleteing your local copy of $1"
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
	echo " (1) -  Abort checkout of $1, so you can add/commit these unsaved changes."
	echo "  2  -  Commit changes and continue checkout of $3"
	echo "  3  -  Stash Changes and continue with checkout of $3"
	echo "  4  -  Revert (reset) all changes to tracked files (ignores untracked files), and continue with checkout of branch $3"
	echo "  5  -  I know what I'm doing, continue with checking out $3 anyways"
	read decision
	echo You chose: $decision
	echo
	if [ -z "$decision" ] || [ $decision -eq 1 ]
		then
		echo "Aborting checkout."
		echo
		exit -1
	elif [ -z "$decision" ] || [ $decision -eq 5 ]
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
	else
		exit 1
	fi
fi

echo "This tells your local git about all changes on fl remote"
echo "git fetch --all --prune"
git fetch --all --prune
echo
echo



echo "This checks out the $1 branch"
echo "git checkout $1"
git checkout $1
echo
echo


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
		echo "merge master into $1? (y) n"
		read decision

		if [ -z "$decision" ] || [ "$decision" = "y" ]
			then
			echo
			echo "Merging $remote/master into $1"
			echo
			echo "git merge $remote/master"
			git merge $remote/master
		fi
	else
		echo "rebase $1 onto master? (y) n"
		read decision
		if [ -z "$decision" ] || [ "$decision" = "y" ]
			then
			echo
			echo "Rebasing $1 onto $remote/master"
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