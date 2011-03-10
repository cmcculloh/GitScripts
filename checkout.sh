echo "##########################################"
echo Checking out branch $1
echo "##########################################"
echo
echo

branchexists=`git branch | grep "$1"`

if [ -n $branchexists ]
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
	echo "(1). Stash Changes and then checkout $1"
	echo "2. Revert all changes to tracked files \(ignores untracked files\), and then checkout $1"
	echo "3. Abort checkout of $1"
	read decision

	if [ -z "$decision" ] || [ $decision -eq 1 ]
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
	elif [ $decision -eq 2 ]
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
		exit 0
	fi
fi

echo This tells your local git about all changes on fl remote
echo git fetch --all --prune
git fetch --all --prune
echo
echo



echo This checks out the $1 branch
echo git checkout $1
git checkout $1
echo
echo


remote=$(git remote)

echo This makes sure the $1 branch is up to date
echo \(if it doesn't exist on the remote yet, don't worry about the warnings\)
echo git pull $remote $1
git pull $remote $1

echo
echo
echo git status
git status
echo
echo

current_branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')

if [ $current_branch = "master" ]
	then
	#do nothing, already on master
	echo
else
	echo Type the number of the choice you want and hit enter
	echo
	echo It is recommended that you merge the current version of master into your
	echo branch to make future merges with dev, qa, and master easier. If you
	echo have not yet pushed your branch to remote, you can rebase \(whic is best\!\)
	echo "(1). merge master into $1"
	echo 2. rebase $1 to master
	echo 3. do neither \(not recommended\)
	echo "defaults to 1"
	read decision

	if [ -z "$decision" ] || [ $decision -eq 1 ]
		then
		echo
		echo Merging $remote\/master into $1
		echo
		echo git merge $remote\/master
		git merge $remote\/master

	elif [ $decision -eq 2 ]
		then
		echo
		echo Rebasing $1 onto $remote\/master
		echo
		echo git rebase $remote\/master
		git rebase $remote\/master
	fi


	echo
	echo
	echo git status
	git status
	echo 
	echo
fi