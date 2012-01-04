$loadfuncs

startingBranch="master"
if [ -n $3 ] && [ "$3" != " " ] && [ "$3" != "" ]
	then
	startingBranch=$3
fi


echo ${H1}
echo ${H1HL}
echo "Creating new branch: ${STYLE_NEWBRANCH_H1}\`${1}\`${H1} based off of ${STYLE_OLDBRANCH_H1}\`${startingBranch}\`${H1} "
echo ${H1HL}
echo ${X}
echo ${O}
echo ${H2HL}
echo "# git status --porcelain"
git status --porcelain
echo ${X}${I}
echo ${HL}
echo "Type the number of the choice you want and hit enter"
echo " (1) -  Create branch ${STYLE_NEWBRANCH}\`${1}\`${I} from ${STYLE_OLDBRANCH_H1}\`${startingBranch}\`${I}"
echo "  2  -  Stash Changes and create branch $1 from ${STYLE_OLDBRANCH_H1}\`${startingBranch}\`${I}"
echo "  3  -  Revert all changes to tracked files \(ignores untracked files\), and create branch $1 from ${STYLE_OLDBRANCH_H1}\`${startingBranch}\`${I}"
echo "  4  -  Abort creation of branch $1 from ${STYLE_OLDBRANCH_H1}\`${startingBranch}\`${I}"
echo ${HL}${X}
read decision
echo 
echo "${O}You chose: $decision"
echo ${X}

if [ -z "$decision" ] || [ $decision -eq 1 ]
	then
	echo continuing...
elif [ $decision -eq 4 ]
	then
	echo "Aborting creation of branch ${STYLE_NEWBRANCH}\`${1}\`${X}"
	exit 1

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
echo This tells your local git about all changes on the remote
echo git fetch --all --prune
git fetch --all --prune
echo
echo

if [ "$startingBranch" = "master" ]
	then
	echo
	echo
	echo This branches master to create a new branch named $1
	echo and then checks out the $1 branch
	echo git checkout master
	git checkout master

	echo
	echo
	git status

  	remote=$(git remote)

	echo
	echo
	echo git pull $remote master
	git pull $remote master

	echo
	echo
	git status

	echo
	echo
	echo git checkout -b $1
	git checkout -b $1
	git config branch.$1.remote $remote
	git config branch.$1.merge refs/heads/$1


	remotes_string=$(git remote);
	c=0;

	for remote in $remotes_string; 
	do 
	echo "$c: $remote";
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
			remote=$(echo ${remotes[$i]} | sed 's/[a-zA-Z0-9\-]+(\/\{1\}[a-zA-Z0-9\-]+)//p')

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

		remote=$(echo ${remotes[$remote]} | sed 's/\// /')
	fi

	echo "remote: $remote"
	chosenremoteexists=`git remote | grep "${remote}"`
	if [ -z "$remote" ] || [ "$remote" = "" ] ; then
		echo ${E}"####################################################################################"
		echo "ABORTING: pushing requires a remote to continue                               "
		echo "####################################################################################"
		echo ${X}
		exit 0
	elif [ -n "$chosenremoteexists" ] ; then
		echo ${h2}"You chose: ${COL_CYAN}${remote}${h2}"
		echo ${X}
		eval "git push ${remote} ${1}"
		git fetch --all --prune

	else
		echo ${E}"You chose: ${COL_CYAN}${remote}${E}"
		echo "404 NOT FOUND. The requested REMOTE /${remote} was not found on this server."
		echo ${X}
	fi



	echo
	echo
	git status
else
	echo
	echo
	checkout.sh $startingBranch

	echo "You are about to checkout branch $startingBranch in order to create a new branch named $1"
	echo 'Do not do this unless you truly know what you are doing, and why!'
	echo "The only reason to do this is if your new branch relies on branch $startingBranch"
	echo 'Please type "I understand" and hit enter to continue'
	echo 'or type anything else or just hit enter to abort'
	read iunderstand
	if [ "$iunderstand" = "I understand" ]
		then
		echo This branches $startingBranch to create a new branch named $1
		echo git checkout -b $1 $startingBranch
		git checkout -b $1 $startingBranch
		git config branch.$1.remote $remote
		git config branch.$1.merge refs/heads/$1
		git push $remote $1

	else
		echo 'You have chosen.... wisely.'
		exit 1
	fi
fi