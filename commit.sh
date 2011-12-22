#!/bin/bash


function __parse_git_branch {
 git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

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

		if [ untrackedfiles -gt 0 ]
			then

			echo ""
			echo ${O}
			echo "------------------------------------------------------------------------------------"
			echo "# git status"
			#${TEXT_NORM}
			#${TEXT_BRIGHT}
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
#${TEXT_NORM}
#${TEXT_BRIGHT}
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
	remote=$(git remote)

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
	#${TEXT_NORM}
	#${TEXT_BRIGHT}
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



echo "Clear screen? (y) n"
read YorN
if [ "$YorN" = "y" ] || [ "$YorN" = "" ]
	then

	echo ""
	echo "Clearing screen now!"
	echo ""
	clear
fi



