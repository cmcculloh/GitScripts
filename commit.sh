#!/bin/bash
## /*
#	@usage commit <message> [-aA]
#
#	@description
#	Commits already-staged work to a branch with a few extra benefits. The branch name
#	is prepended to the commit message so that all commits are easily associated with
#	their branch. The commit summary message is also automatically suppressed.
#
#	Non-staged work can be staged via the available options, which are described below.
#	description@
#
#	@options
#	-a	Automatically stage modified and deleted files before committing.
#	-A	Automatically stage ALL tracked/untracked files before committing.
#	options@
#
#	@notes
#	- The options for this command must come AFTER the message since the -m
#	option is automatically passed to git commit during processing.
#	- If there are untracked files in the working tree and the user passes the -a
#	option, he/she will be prompted to add the untracked files as well.
#	notes@
#
#	@examples
#	1) commit "I know I added some untracked files, so I'll pass the right option" -A
#	examples@
#
#	@dependencies
#	clear-screen.sh
#	functions/0100.bad_usage.sh
#	functions/5000.branch_exists.sh
#	functions/5000.is_branch_protected.sh
#	functions/5000.parse_git_branch.sh
#	functions/5000.parse_git_status.sh
#	functions/5000.set_remote.sh
#	dependencies@
## */
$loadfuncs


echo ${X}
numArgs=$#

# parse arguments
if (( numArgs > 0 && numArgs < 4 )); then
	until [ -z "$1" ]; do
		[ "$1" == "--admin" ] && [ $ADMIN ] && isAdmin=true
		{ [ "$1" == "-a" ] || [ "$1" == "-A" ]; } && flag=$1
		! echo "$1" | egrep -q "^-" && msg="$1"
		shift
	done
else
	__bad_usage commit "Invalid number of parameters."
	exit 1
fi

# conditions that should cause the script to halt immediately:
# make sure SOMETHING is staged if user doesn't specify flag
if ! __parse_git_status staged && [ ! $flag ]; then
	echo
	echo ${E}"  You haven't staged any changes to commit! Aborting...  "${X}
	exit 1
fi

startingBranch=$(__parse_git_branch)
if [ -z "$startingBranch" ]; then
	echo ${E}"  Unable to determine current branch.  "${X}
	exit 1
fi


echo
echo ${H1}${H1HL}
echo "  Committing changes to branch: ${H1B}\`${startingBranch}\`${H1}  "
echo ${H1HL}${X}

echo
echo
echo "Checking status..."
echo ${O}${H2HL}
echo "$ git status"
git status
echo ${O}${H2HL}${X}

# check to see if user wants to add all modified/deleted files
if [ $flag ]; then
	case $flag in
		"-a")
			if __parse_git_status untracked; then
				echo
				echo
				echo ${Q}"Would you like to run ${A}git add -A${Q} to add untracked files as well? y (n)"${X}
			read yn
			if [ "$yn" == "y" ] || [ "$yn" == "Y" ]; then
				echo
					echo
					echo "Adding all modified and untracked files..."
					echo ${O}${H2HL}
					echo "$ git add -A"
					git add -A
					echo ${O}${H2HL}${X}
			fi
		fi
			;;

		"-A")
			flag=""
			echo "Adding all modified and untracked files..."
			echo ${O}${H2HL}
			echo "$ git add -A"
			git add -A
			echo ${O}${H2HL}${X}
			;;

		*)
			__bad_usage commit "Invalid parameter ($flag)."
			exit 1
			;;
	esac
fi


echo
echo
echo "Committing and displaying branch changes..."
echo ${O}${H2HL}
echo "$ git commit -q -m \"(${startingBranch}) $1\" $flag"
git commit -q -m "(${startingBranch}) $1" $flag
echo ${O}
echo
echo "$ git diff-tree --stat HEAD"
git diff-tree --stat HEAD
echo ${O}${H2HL}${X}
echo
echo
echo "Checking status..."
echo ${O}${H2HL}
echo "$ git status"
git status
echo ${O}${H2HL}${X}
echo

# wrap up...
if [ $isAdmin ]; then
	"${gitscripts_path}"push.sh --admin "$startingBranch"
else
	"${gitscripts_path}"push.sh "$startingBranch"
fi
"${gitscripts_path}"clear-screen.sh

exit
