echo "##########################################"
echo Merging from $1 into $3
echo "##########################################"
echo
echo
echo git status
git status
echo
echo

echo Type the number of the choice you want and hit enter
echo 1. Continue with merging from $1 into $3
echo 2. Stash Changes and continue with merging from $1 into $3
echo 3. Revert all changes to tracked files \(ignores untracked files\), and continue with merging from $1 into $3
echo 4. Abort merging from $1 into $3
read decision
echo You chose: $decision
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

echo This makes sure the $1 branch is up to date
echo \(if it doesn't exist on the remote yet, don't worry about the warnings\)
echo git pull fl $1
git pull fl $1


echo This checks out the $3 branch
echo git checkout $3
git checkout $3
echo
echo

echo This makes sure the $3 branch is up to date
echo \(if it doesn't exist on the remote yet, don't worry about the warnings\)
echo git pull fl $3
git pull fl $3

echo
echo
echo This merges from $1 into $3
echo git merge $1
git merge $1


echo
echo
echo git status
git status
echo
echo

echo
echo

echo "Would you like to push? y (n)"
read YorN
if [ "$YorN" = "y" ]
	then
	remote=$(git remote)
	git push $remote head
fi