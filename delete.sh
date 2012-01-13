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
	deleteBranch=$1
	$loadfuncs
fi

numArgs=$#
# parse arguments
if (( numArgs > 0 && numArgs < 4 )); then
	until [ -z "$1" ]; do
		if [ "$1" == "--admin" ] && [ $ADMIN ];then
			isAdmin=true
			echo "set isAdmin to true"
		fi
		! echo "$1" | egrep -q "^-" && msg="$1"
		shift
	done
#else
#	__bad_usage commit "Invalid number of parameters."
#	exit 1
fi

echo
echo ${H1}${H1HL}
echo "  Deleting branch: ${H1B}\`$deleteBranch\`${H1}  "
echo ${H1HL}${X}
echo
echo
checkbranch=`git status | grep "$deleteBranch"`
echo "$checkbranch"

if [ -n "$checkbranch" ]
	then
	echo
	echo
	echo "You are currently on branch \`$deleteBranch\`. You cannot delete a branch you are on."
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
		echo checking out $enteredBranchName before deleting branch $deleteBranch
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


trydelete=`git branch -d $deleteBranch 2>&1 | grep "error"`
echo "$trydelete"
echo
if [ -n "$trydelete" ]
	then
	echo "Delete failed!"
	echo "force delete? y (n)"
	read forcedelete
	if [ "$forcedelete" = "y" ]
		then
		trydelete=`git branch -D $deleteBranch 2>&1 | grep "error:"`
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


if [ $isAdmin ]; then
	onremote=`git branch -r | grep "$deleteBranch"`
	if [ -n "$onremote" ]
		then
		echo
		echo "delete remote copy of branch? y (n)"
		read deleteremote

		if [ -n "$deleteremote" ] && [ "$deleteremote" = "y" ]
			then

			__is_branch_protected --all "$deleteremote" && isProtected=true
			if [ $isProtected ]; then
				echo "${W}WARNING: $deleteBranch is a protected branch."
				echo "Are you SURE you want to delete remote copy? yes (n)${X}"
				read yn
				if [ -z "$yn" ] || [ "$yn" != "yes" ]
					then
					echo "aborting delete of remote branch..."
					exit 1
				fi
			fi


			__set_remote
			echo
			echo "deleting $deleteBranch on $_remote!"
			echo
			remote=$_remote
			echo "git push $remote :$deleteBranch"
			git push $remote :$deleteBranch
		fi
	else
		echo "not on remote"
	fi
else
	echo "\$isAdmin=$isAdmin"
fi

exit
