#!/bin/bash


function __parse_git_branch {
 git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}


startingBranch="$(__parse_git_branch)"



echo ${H1}
echo "####################################################################################"
echo "Committing changes to branch ${COL_CYAN}${startingBranch}${COL_NORM}"
echo "####################################################################################"
echo ${X}
echo ""


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
echo "# git commit -q -m \"$(__parse_git_branch) $1\" $2"
git commit -q -m "$(__parse_git_branch) $1" $2
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



