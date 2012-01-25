#!/bin/bash
## /*
#	@usage pullscripts
#
#	@description
#	This is a quick way to update the GitScripts master branch. It takes note of the current branch
#	and the current working directory of the user, updates master, then returns the user
#	to his/her previous working conditions. Furthermore, the script will fail if there are
#	changed/staged files in the working tree. Untracked files don't make a difference.
#	description@
#
#	@dependencies
#	functions/5000.parse_git_branch.sh
#	functions/5000.parse_git_status.sh
#	dependencies@
#
#	@file pullscripts.sh
## */
$loadfuncs


echo ${X}

# make sure there are no current changes needing to be committed/staged.
if __parse_git_status clean || { ! __parse_git_status modified && ! __parse_git_status staged; }; then

	# if there is a space in the directory, storing it in a variable won't work with cd
	pushd $(pwd) > /dev/null
	cd ${gitscripts_path}

	cb=$(__parse_git_branch)

	# We are assuming no changes have been made to these files.
	echo ${H1}${H1HL}
	echo "  Pulling in GitScripts master changes...  "
	echo ${H1HL}${X}
	echo
	echo
	echo "${A}Fetch${X} changes, ${A}checkout${X} ${B}master${X}, and ${A}pull${X} the changes in..."
	echo ${O}${H2HL}
	echo "$ git fetch --all --prune"
	git fetch --all --prune

	if [ "$cb" != "master" ]; then
		echo
		echo
		echo ${O}"$ git checkout master"
		git checkout master
	fi

	echo
	echo
	if __parse_git_status clean || { ! __parse_git_status modified && ! __parse_git_status staged; }; then
		# The GitScripts project is expected to live at GitHub for the foreseeable future, so "origin" is hard-coded.
		echo ${O}"$ git pull origin master"
		git pull origin master
		echo ${O}${H2HL}${X}
	else
		echo ${E}"  Error: Gitscripts files have been changed. Please reset or commit changes before trying again. Aborting...  "${X}
		exit 1
	fi
	echo
	echo

	# Normal users will never mess with the gitscripts project, so the branch should always be master, but in case it isn't...
	if [ -n "$cb" ] && [ "$cb" != "master" ]; then
		# we will NOT use checkout.sh since it might be a file with a change. this can cause script failure.
		echo "Now returning you to your original branch: ${B}\`${cb}\`${X}"
		echo "It is recommended that you manually ${A}pull${X} in ${B}master${X} to this branch afterwards."
		echo ${O}${H2HL}
		echo "$ git checkout ${cb}"
		git checkout "$cb"
		echo ${O}${H2HL}${X}
		echo
		echo
	fi

	echo "Now returning you to your original working directory..."
	popd > /dev/null
else
	echo ${E}"  Error: Your working directory must be clean with the exception of untracked files before GitScripts can continue. Aborting...  "${X}
	exit 1
fi

exit
