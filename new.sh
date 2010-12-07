branch="fl/master"
if [ -n $3 ]
	then
	branch=$3
fi

echo "##########################################"
echo Creating new branch $1 from $branch
echo "##########################################"
echo
echo
echo git status
git status
echo
echo

echo Type the number of the choice you want and hit enter
echo 1. Create branch $1
echo 2. Stash Changes and create branch $1
echo 3. Revert all changes to tracked files \(ignores untracked files\), and create branch $1
echo 4. Abort creation of branch $1
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

echo
echo
echo This tells your local git about all changes on fl remote
echo git fetch --all --prune
git fetch --all --prune
echo
echo

if [ "$branch" = "fl/master" ]
	then
	echo This branches fl/master to create a new branch named $1
	echo and then checks out the $1 branch
	echo git checkout --no-track -b $1 fl/master
	git checkout --no-track -b $1 fl/master
else
	/d/automata/flgitscripts/checkout.sh $branch

	echo "You are about to branch $branch to create a new branch named $1"
	echo 'YOU SHOULD PROBABLY NOT BE DOING THIS!!!!'
	echo "The only reason to do this is if your new branch relies on branch $branch"
	echo 'Please enter "I understand" and hit enter to continue'
	echo 'or type anything else or just hit enter to abort'
	read iunderstand
	if [ "$iunderstand" = "I understand" ]
		then
		echo This branches $branch to create a new branch named $1
		echo git checkout -b $1 $branch
		git checkout -b $1 $branch
	else
		echo 'You have chosen.... wisely.'
		exit 1
	fi
fi