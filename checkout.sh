echo "##########################################"
echo Checking out branch $1
echo "##########################################"
echo
echo

echo git status
git status
echo
echo

echo Type the number of the choice you want and hit enter
echo 1. Checkout $1
echo 2. Stash Changes and then checkout $1
echo 3. Revert all changes to tracked files \(ignores untracked files\), and then checkout $1
echo 4. Abort checkout of $1
read decision


if [ $decision -eq 1 ]
	then
	echo continuing...
elif [ $decision -eq 2 ]
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
elif [ $decision -eq 3 ]
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

if [ $current_branch -eq "master" ]
	then
	#do nothing, already on master
	echo "done"
else
	echo Type the number of the choice you want and hit enter
	echo
	echo It is recommended that you merge the current version of master into your
	echo branch to make future merges with dev, qa, and master easier. If you
	echo have not yet pushed your branch to remote, you can rebase \(whic is best\!\)
	echo 1. merge master into $1
	echo 2. rebase $1 to master
	echo 3. do neither \(not recommended\)
	read decision

	if [ $decision -eq 1 ]
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