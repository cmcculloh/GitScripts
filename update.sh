#!/bin/bash
## /*
#	@usage update
#
#	@description
#	This script brings your local working branch copy up to date with
#	it's remote branch and master.
#
#	This script:
#	1) Fetches all
#	2) Sets your remote
#	3) Pulls the remote version of you current branch
#	4) Pulls the remote master
#	5) Asks if you want to push (and then pushes if so)
#	description@
#
#	@dependencies
#	functions/1000.parse_git_branch.sh
#	functions/1000.set_remote.sh
#	functions/5000.merge_master.sh
#	functions/5000.merge_development.sh
#	push.sh
#	dependencies@
#
#	@file update.sh
## */
$loadfuncs


echo ${X}
__set_remote

if [ -n "$_remote" ]; then
	echo "${A}Fetch${X} all updates from ${COL_GREEN}${_remote}${X}..."
	echo ${O}${H2HL}
	echo "$ git fetch --all --prune"
	git fetch --all --prune
	echo ${O}${H2HL}${X}
	echo
	echo

	cb=$(__parse_git_branch)
	if [ -z "$cb" ]; then
		echo ${E}"  Unable to determine the current branch! Aborting...  "${X}
		exit 1
	fi

	echo "${A}Pull${X} in changes from this branch and then from ${B}\`master\`${X},"
	echo "check our status, and then optionally ${A}push${X} the updates back up."
	echo ${O}${H2HL}${X}


	if [ "${cb}" != "master" ]; then
		echo "$ git pull ${_remote} ${cb}"
		git pull ${_remote} $cb
	fi
	echo ${O}

	echo
	echo "Attempt to pull ${B}\'${_remote} master\'${X}? (y) n"
	read yn
	if [ -z "$yn" ] || [ "$yn" = "y" ]; then
		echo "$ git pull ${_remote} master"
		git pull ${_remote} master
		echo ${O}
	fi

	if __parse_git_status modified; then
		echo "Potential submodule changes detected. ${A}Update submodule${O}? (y) n"
		read yn
		if [ -z "$yn" ] || [ "$yn" = "y" ]; then
			echo "updating submodule..."
			git submodule update
		fi
	fi
	echo
	echo "$ git status"
	git status
	echo

	"${gitscripts_path}"push.sh "$1"
	echo ${O}${H2HL}${X}
	echo
	echo "Update complete!"
else
	echo ${E}"  No remote configured for update! Aborting...  "${X}
	exit 1
fi


exit
