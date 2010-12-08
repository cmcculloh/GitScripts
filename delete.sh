echo "##########################################"
echo Deleting new branch $1
echo "##########################################"

echo
echo
echo git status
git status
echo
echo

echo Preparing to delete branch $1,
echo please enter the number of your choice below and hit enter
echo 1. Delete branch $1
echo 2. Force Delete branch $1 \(if you tried once already and it didn\'t work\)
echo 3. Checkout master and then delete branch $1 \(You cannot delete a branch you are currently on\)
echo 4. Specify a branch to checkout and then delete branch $1
echo 5. Abort
read choice

branchName='master'
if [ $choice -eq 1 ]
	then
	echo deleting branch $1
	echo git branch -d $1

	git branch -d $1
	exit
elif [ $choice -eq 2 ]
	then
	echo force deleting branch $1
	echo git branch -D $1

	git branch -D $1
	exit
elif [ $choice -eq 3 ]
	then
	echo checking out master before deleting branch $1

	${gitscripts_path}checkout.sh master
elif [ $choice -eq 4 ]
	then
	echo please specify the branch you wish to check out,
	echo or enter \"abort\" to quit
	read enteredBranchName
	if [ "$enteredBranchName" = "abort" ]
		then
		exit
	else
		branchName=$enteredBranchName
	fi
	echo checking out $branchName before deleting branch $1

	${gitscripts_path}checkout.sh $branchName
elif [ $choice -eq 5 ]
	then
	exit 1
fi

if [ $? -ne 1 ]
	then
	echo
	echo Type the number of the choice you want and hit enter
	echo 1. Continue with deletion of branch $1
	echo 2. Abort Deletion and check branch $1 back out
	echo 3. Abort and stay on branch $branchName
	read decision
	echo You chose: $decision
	if [ $decision -eq 1 ]
		then
		echo continuing...
		echo git branch -d $1

		git branch -d $1
	elif [ $decision -eq 2 ]
		then
		echo aborting and checking out branch $1

		${gitscripts_path}checkout.sh $1
	else
		exit
	fi
else
	exit 1
fi