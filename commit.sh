#!/bin/bash


function __parse_git_branch {
 git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

#http://stackoverflow.com/questions/2657935/checking-for-a-dirty-index-or-untracked-files-with-git
function evil_git_num_untracked_files {
 git status --porcelain 2>/dev/null| grep "^??" | wc -l
}

startingBranch="$(__parse_git_branch)"
untrackedfiles="$(evil_git_num_untracked_files)"


echo ${H1}
echo "####################################################################################"
echo "Committing changes to branch ${COL_CYAN}${startingBranch}${COL_NORM}"
echo "####################################################################################"
echo ${X}
echo ""

if [ -n $2 ]
	then

	if [ $2 = "-A" ] || [ $2 = "-a" ]
		then
		flag="-a"
	fi

	if [ $2 = "-A" ]
		then
		echo "------------------------------------------------------------------------------------"
		echo "# git add -A"
		git add -A
		echo "------------------------------------------------------------------------------------"
	elif [ $2 = "-a" ]
		then

		if [ $untrackedfiles -gt 0 ]
			then
			echo ""
			echo ${O}
			echo "------------------------------------------------------------------------------------"
			echo "# git status"
			#${STYLE_NORM}
			#${STYLE_BRIGHT}
			git status
			echo ${X}

			echo ""
			echo "Would you like to run 'git add -A' to add untracked files as well? y (n)"
			read yn
			if [ "$yn" = "y" ]
				then
				echo "------------------------------------------------------------------------------------"
				echo "# git add -A"
				git add -A
				echo "------------------------------------------------------------------------------------"
			fi
		fi
	fi
fi

echo ""
echo ${O}
echo "------------------------------------------------------------------------------------"
echo "# git status"
#${STYLE_NORM}
#${STYLE_BRIGHT}
git status
echo ${X}



echo ""
echo ${O}
echo "------------------------------------------------------------------------------------"
echo "# git commit -q -m \"($(__parse_git_branch)) $1\" $2"
git commit -q -m "($(__parse_git_branch)) $1" $flag
echo "------------------------------------------------------------------------------------"
echo ${X}


echo ""
echo ${O}
echo "------------------------------------------------------------------------------------"
echo "# git diff-tree --stat HEAD"
git diff-tree --stat HEAD
echo "------------------------------------------------------------------------------------"
echo ${X}


echo
echo

echo ${H2}
echo "Would you like to push? y (n)"
echo ${X}
read YorN
if [ "$YorN" = "y" ]
	then
	echo ${O}"------------------------------------------------------------------------------------"
	echo "Choose a remote (or just hit enter to abort):"
	echo "------------------------------------------------------------------------------------"
	remotes=()
	#eval "$(git for-each-ref --shell --format='branches+=(%(refname:short))' refs/heads/)"
	eval "$(git for-each-ref --shell --format='remotes+=(%(refname:short))' refs/remotes/)"
	for (( i = 0 ; i < ${#branches[@]} ; i++ ))
	do
		if [ $i -le "9" ] ; then
			index="  "$i
		elif [ $i -le "99" ] ; then
			index=" "$i
		else
			index=$i
		fi
		echo "$index: " ${remotes[$i]}
		# yadda yadda
	done
	echo ${I}"Choose a remote (or just hit enter to abort):"
	read remote
	echo ${X}


	chosenremoteexists=`git remote | grep "${remotes[$remote]}"`
	if [ -z "$remote" ] || [ "$remote" = "" ] ; then
		echo ${E}"####################################################################################"
		echo "ABORTING: pushing requires a remote to continue                               "
		echo "####################################################################################"
		echo ${X}
		exit 0
	elif [ -n "$chosenremoteexists" ] ; then
		echo ${h2}"You chose: ${COL_CYAN}${remotes[$remote]}${h2}"
		echo ${X}
		eval "git push ${remotes[$remote]} HEAD"

	else
		echo ${E}"You chose: ${COL_CYAN}${remotes[$remote]}${E}"
		echo "404 NOT FOUND. The requested REMOTE /${remotes[$remote]} was not found on this server."
		echo ${X}
	fi









	echo ""
	echo ${O}
	echo "------------------------------------------------------------------------------------"
	echo "# git push $remote HEAD"
	git push $remote HEAD
	echo "------------------------------------------------------------------------------------"
	echo ${X}
	echo


	echo ${H2}
	echo "####################################################################################"
	echo "Status after push:"
	echo "####################################################################################"
	echo ${X}

	echo ""
	echo ${O}
	echo "------------------------------------------------------------------------------------"
	echo "# git status"
	#${STYLE_NORM}
	#${STYLE_BRIGHT}
	git status
	echo ${X}

fi


echo "Check for remote changes? (y) n"
echo ""
read YorN
if [ "$YorN" = "y" ] || [ "$YorN" = "" ]
	then
	
	echo "NOT ACTUALLY CHECKING FOR CHANGES RIGHT NOW --- TBD LATER"
fi


if [ "$clearscreenanswer" = "n" ]
	then
	echo "Clear screen? y (n)"
	read YorN
	if[ "$YorN" = "" ]
		then
		YorN=n
	fi
else
	echo "Clear screen? (y) n"
	read YorN
	if[ "$YorN" = "" ]
		then
		YorN=y
	fi
fi

if [ "$YorN" = "y" ]
	then

	echo ""
	echo "Clearing screen now!"
	echo ""
	clear
fi




