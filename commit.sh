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
#	functions/5000.parse_git_branch.sh
#	functions/5000.parse_git_status.sh
#	functions/5000.set_remote.sh
#	dependencies@
## */
$loadfuncs


# conditions that should cause the script to halt immediately:
# missing commit message
if [ -z "$1" ]; then
	__bad_usage commit "Commit message is required."
	exit 1
fi


# make sure SOMETHING is staged if user doesn't specify flag
if ! __parse_git_status staged && [ -z "$2" ]; then
	echo
	echo ${E}"  You haven't staged any changes to commit! Aborting...  "${X}
	exit 1
fi


startingBranch=$(__parse_git_branch)
if [ -z "$startingBranch" ]; then
	echo ${E}"Unable to determine current branch."${X}
	exit 1
fi


echo
echo ${H1}${H1HL}
echo "Committing changes to branch: \`${startingBranch}\`"
echo ${H1HL}${X}

echo
echo
echo "Checking status..."
echo ${O}${H2HL}
echo "$ git status"
git status
echo ${H2HL}${X}

# check to see if user wants to add all modified/deleted files
if [ -n "$2" ]; then
	flag=$2
	case $2 in
		"-a")
			if __parse_git_status untracked; then
				echo
				echo
				echo ${Q}"Would you like to run ${COL_MAG}git add -A${COL_NORM} to add untracked files as well? y (n)"${X}
			read yn
			if [ "$yn" == "y" ] || [ "$yn" == "Y" ]; then
				echo
					echo
					echo "Adding all modified and untracked files..."
					echo ${O}${H2HL}
					echo "$ git add -A"
					git add -A
					echo ${H2HL}${X}
			fi
		fi
			;;

		"-A")
			flag=""
			echo "Adding all modified and untracked files..."
			echo ${O}${H2HL}
			echo "$ git add -A"
			git add -A
			echo ${H2HL}${X}
			;;

		*)
			__bad_usage commit "Invalid value for second parameter."
			exit 1
			;;
	esac
fi


echo
echo
echo "Committing and displaying branch changes..."
echo ${O}${H2HL}
echo "$ git commit -q -m \"($startingBranch) $1\" $flag"
git commit -q -m "(${startingBranch}) $1" $flag
echo
echo
echo "$ git diff-tree --stat HEAD"
git diff-tree --stat HEAD
echo ${H2HL}${X}
echo
echo
echo "Checking status..."
echo ${O}${H2HL}
echo "$ git status"
git status
echo ${H2HL}${X}
echo
echo
echo ${I}"Would you like to push? y (n)"${X}
read YorN
echo
if [ "$YorN" == "y" ] || [ "$YorN" == "Y" ]; then
	__set_remote
	if [ -n "$_remote" ]; then
		echo
		echo "Now pushing to:${X} ${COL_GREEN} ${_remote} ${COL_NORM}"
		echo ${O}${H2HL}
		echo "$ git push ${_remote} ${startingBranch}"
		git push "$_remote" "$startingBranch"
		echo ${H2HL}${X}

	else
		echo ${E}"  No remote could be found. Push aborted.  "${X}

	fi
fi

"${gitscripts_path}clear-screen.sh"

exit
