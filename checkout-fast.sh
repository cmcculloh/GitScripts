#!/bin/bash
# checkout
# checks out a git branch


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
echo "Checking out branch ${COL_CYAN}$1${COL_NORM}"
echo "##########################################"
echo
echo

echo

if [ -z "$1" ] || [ "$1" = " " ]
	then
	git branch
	echo "${COL_RED}WARNING:${COL_NORM} You must specify a branch to check out."
	exit -1
fi


branchexists=`git branch | grep "$1"`

if [ -n "$branchexists" ]
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
					echo "continue checking out ${COL_CYAN}$1${COL_NORM}? y (n)"
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
			echo "not deleteing your local copy of ${COL_CYAN}$1${COL_NORM}"
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
	echo "${COL_YELLOW}ABORTING${COL_NORM} checkout of ${COL_CYAN}$1${COL_NORM}"
	echo
	exit -1
fi

echo "This tells your local git about all changes on fl remote"
echo "git fetch --all --prune"
git fetch --all --prune
echo
echo



echo "This checks out the ${COL_CYAN}$1${COL_NORM} branch"
echo "git checkout $1"
git checkout $1
trycheckout=`git checkout $1 2>&1 | grep "error"`
echo
if [ -n "$trycheckout" ]
	then
	echo "Checkout failed!"
	exit -1
fi


remote=$(git remote)
onremote=`git branch -r | grep "$1"`

if [ -n "$onremote" ]
	then
	echo "git pull $remote $1"
	git pull $remote $1
fi

echo
echo
echo git status
git status
echo
echo

if [ $1 = "master" ]
	then
	#do nothing, already on master
	echo
else
	if [ -n "$onremote" ]
		then


			echo
			echo "Merging $remote/master into ${COL_CYAN}$1${COL_NORM}"
			echo
			echo "git merge $remote/master"
			git merge $remote/master
	fi

	echo
	echo
	echo git status
	git status
	echo
	echo
fi