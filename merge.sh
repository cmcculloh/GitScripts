#!/bin/bash
# merge
# merges one git branch into another

. /etc/git-completion.bash


TEXT_BRIGHT=$'\033[1m'
TEXT_DIM=$'\033[2m'
TEXT_NORM=$'\033[0m'
COL_RED=$'\033[31m'
COL_GREEN=$'\033[32m'
COL_VIOLET=$'\033[34m'
COL_YELLOW=$'\033[33m'
COL_MAG=$'\033[35m'
COL_CYAN=$'\033[36m'
COL_WHITE=$'\033[37m'
COL_NORM=$'\033[39m'


echo "##########################################"
echo "Merging from ${COL_YELLOW}$1${COL_NORM} into ${COL_CYAN}$3${COL_NORM}"
echo "##########################################"
echo
echo

if [ "$1" = "dev" ] || [ "$1" = "qa" ]
	then
	echo
	echo "${COL_RED}WARNING: merging ${COL_YELLOW}from${COL_RED} $1 not allowed. You may only merge ${COL_YELLOW}INTO ${COL_YELLOW}$1${COL_NORM}."
	echo
	echo
	exit -1
fi

if [ "$3" = "stage" ] || [ "$3" = "master" ]
	then
	echo
	echo "${COL_RED}WARNING: merging ${COL_YELLOW}into${COL_RED} $3 not allowed.${COL_NORM}"
	echo "${COL_RED}You may only merge ${COL_YELLOW}FROM${COL_RED} $3.${COL_NORM}"
	echo
	echo
	exit -1
fi





if [ $? -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	exit -1
fi

echo This tells your local git about all changes on fl remote
echo git fetch --all --prune
git fetch --all --prune

if [ $? -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "git fetch --all --prune failed"
	exit -1
fi

echo
echo
echo This checks out the $1 branch
echo git checkout $1
${gitscripts_path}checkout.sh $1
result=$?

if [ $result -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "checkout of branch $1 failed"
	exit -1
elif [ $result -eq 255 ]
	then
	echo "Checking out the branch $1 was unsuccessful, aborting merge attempt..."
	exit -1
fi

echo
echo
echo This checks out the $3 branch
echo git checkout $3
${gitscripts_path}checkout.sh $3
result=$?

if [ $result -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "git checkout $3 failed"
	exit -1
elif [ $result -eq 255 ]
	then
	echo "Checking out the branch $3 was unsuccessful, aborting merge attempt..."
	exit -1
fi

echo
echo
echo This merges from $1 into $3
echo git merge $1
git merge $1

if [ $? -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "git merge $1 failed"
	exit -1
fi

statusofmerge=`git status | grep "Unmerged paths"`

if [[ "$statusofmerge" == "# Unmerged paths:" ]];
	then
		echo
		git status
		echo

		echo
		echo "${COL_YELLOW}WARNING: You have unmerged paths!${COL_NORM}"
		echo
		echo "Please ${COL_RED}resolve your merge conflicts${COL_NORM} , then ${COL_YELLOW}run a build and test your build before pushing${COL_NORM} back out.${TEXT_NORM}"
		echo
		echo "Would you like to run the merge tool? (y) n"
		read YorN
		if [ "$YorN" != "n" ]
			then

				git mergetool
			else
				exit -1
		fi
fi

statusofmerge=`git status | grep "Changes to be committed"`

if [[ "$statusofmerge" == "# Changes to be committed:" ]];
	then
		echo
		git status
		echo

		echo "${COL_YELLOW}WARNING: You have uncommitted changes!${COL_NORM}"
		echo
		echo "Please ${COL_RED}add/commit${COL_NORM} any changes you have.${TEXT_NORM}"
		echo "Would you like to commit these changes? (y) n"
		read YorN
		if [ "$YorN" != "n" ]
			then
				echo "please enter a commit message"
				read commitmessage

				source ${gitscripts_path}commit.sh "$commitmessage" -a

			else
				exit -1
		fi
fi

echo
echo
echo git status
git status
echo
echo "Would you like to push? y (n)"
read YorN
if [ "$YorN" = "y" ]
	then
	remote=$(git remote)
	git push $remote head
fi

if [ $? -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "git push $remote $3 failed"
	exit -1
fi