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
#	gitscripts/gsfunctions.sh
#	dependencies@
#
#	@file pullscripts.sh
## */
$loadfuncs


# make sure there are no current changes needing to be committed/staged.
echo
if __parse_git_status clean || { ! __parse_git_status modified && ! __parse_git_status staged; }; then

	# if there is a space in the directory, storing it in a variable won't work with cd
	pushd $(pwd) > /dev/null
	cd ${gitscripts_path}

	cb=$(__parse_git_branch)

	echo ${H1}${H1HL}
	echo " Pulling in GitScripts master changes... "
	echo ${H1HL}${X}
	echo
	echo
	echo "Checkout ${COL_CYAN}master${COL_NORM}, ${COL_MAG}fetch${COL_NORM} changes, and ${COL_MAG}pull${COL_NORM} them in..."
	echo ${O}${H2HL}
	echo "$ git fetch --all --prune"
	git fetch --all --prune
	echo
	echo
	echo "$ git checkout master"
	git checkout master
	echo
	echo
	echo "$ git pull origin master"
	git pull origin master
	echo ${H2HL}${X}
	echo
	echo

	if [ -n "$cb" ] && [ "$cb" != "master" ]; then
		# we will NOT use checkout.sh since it might be a file with a change. this can cause script failure.
		echo "Now returning you to your original branch: ${STYLE_OLDBRANCH_H2}\`${cb}\`${X}"
		echo "It is recommended that you manually ${COL_MAG}pull${COL_NORM} in ${COL_CYAN}master${COL_NORM} to this branch afterwards."
		echo ${O}${H2HL}
		echo "$ git checkout $cb"
		git checkout $cb
		echo ${H2HL}${X}
		echo
		echo
	fi

	echo "Now returning you to your original working directory..."
	popd > /dev/null
else
	echo ${E}"  Error: Your working directory must be clean with the exception of untracked files. Aborting...  "
	exit 1
fi

exit
