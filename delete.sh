#!/bin/bash
## /*
#	@usage delete <branch-name>
#
#	@description
#
#	description@
#
#	@notes
#	-
#	notes@
#
#	@examples
#	1)
#	examples@
#
#	@dependencies
#	checkout.sh
#	functions/0100.bad_usage.sh
#	dependencies@
## */


if [ -z "$1" ]; then
	__bad_usage delete "Branch name to delete is required as the only parameter."
	exit 1
else
	$loadfuncs
fi

echo
echo ${H1}${H1HL}
echo "  Deleting branch: ${H1B}\`$1\`${H1}  "
echo ${H1HL}${X}
echo
echo
checkbranch=`git status | grep "$1"`
echo "$checkbranch"

if [ -n "$checkbranch" ]
	then
	echo
	echo
	echo "You are currently on branch \`$1\`. You cannot delete a branch you are on."
	echo "(1) Checkout master"
	echo "2 Checkout another branch"
	echo "3 Abort"
	read choice

	if [ -z "$choice" ] || [ $choice -eq 1 ]
		then
		echo
		echo "git checkout master"
		${gitscripts_path}checkout.sh master
		echo
		echo
	elif [ $choice -eq 2 ]
		then
		echo "please specify the branch you wish to check out,"
		echo "or enter \"abort\" to quit"
		read enteredBranchName
		if [ "$enteredBranchName" = "abort" ]
			then
			exit 0
		fi
		echo
		echo checking out $enteredBranchName before deleting branch $1
		echo
		echo

		${gitscripts_path}checkout.sh $enteredBranchName
	elif [ $choice -eq 3 ]
		then
		exit 0
	fi

	if [ $? -lt 0 ]
		then
		echo
		echo "something went wrong!"
		echo
		echo "git status"
		git status

		exit -1
	fi
fi


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
		trydelete=`git branch -D $1 2>&1 | grep "error:"`
		echo "$trydelete"
		echo
		if [ -n "$trydelete" ]
			then
			echo "force delete failed!"
			exit -1
		else
			echo "force delete succeeded!"
			echo
		fi
	fi
else
	echo "delete succeeded!"
	echo
fi


numArgs=$#
# parse arguments
if (( numArgs > 0 && numArgs < 4 )); then
	until [ -z "$1" ]; do
		[ "$1" == "--admin" ] && [ $ADMIN ] && isAdmin=true
#		{ [ "$1" == "-a" ] || [ "$1" == "-A" ]; } && flag=$1
		! echo "$1" | egrep -q "^-" && msg="$1"
		shift
	done
#else
#	__bad_usage commit "Invalid number of parameters."
#	exit 1
fi

if [ $isAdmin ]; then
	onremote=`git branch -r | grep "$1"`
	if [ -n "$onremote" ]
		then
		echo
		echo "delete remote copy of branch? y (n)"
		read deleteremote

		if [ -n "$deleteremote" ] && [ "$deleteremote" = "y" ]
			then

			__is_branch_protected --push "$startingBranch" && isProtected=true
			if [ $isProtected ]; then
				echo "${W}WARNING: This is a protected branch. Are you SURE you want to delete remote? yes (n)${X}"
				read yn
				if [ -z "$yn" ][ "$yn" != "yes" ]
					then
					exit 1
				fi
			fi

			echo
			echo "deleting remote!"
			echo
			remote=$(git remote)
			echo "git push $remote :$1"
			git push $remote :$1
		fi
	fi
fi

exit
