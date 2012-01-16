#!/bin/bash
## /*
#	@usage push [branch-name]
#
#	@description
#	This is a quick script that pushes a specified branch or the current branch to
#	the remote, if it exists. To push a specific branch, simply include it as the
#	first parameter when using this script.
#	description@
#
#	@options
#	-q, --quiet	Suppress the "Pushing not allowed" warning message and silently exit.
#	options@
#
#	@examples
#	1) push
#	   # pushes current branch
#	2) push some-other-branch
#	   # pushes some-other-branch...
#	examples@
#
#	@dependencies
#	functions/5000.branch_exists_local.sh
#	functions/5000.parse_git_branch.sh
#	functions/5000.set_remote.sh
#	dependencies@
## */
$loadfuncs


# reset styles
echo ${X}

# parse params
numArgs=$#
if (( numArgs > 0 && numArgs < 3 )); then
	until [ -z "$1" ]; do
		[ "$1" = "--admin" ] && [ "$ADMIN" = "true" ] && isAdmin=true
		{ [ "$1" = "-q" ] ||  [ "$1" = "--quiet" ]; } && isQuiet=true
		! echo "$1" | egrep -q "^-" && branch="$1"
		shift
	done
fi

# setup FAILURE conditions
# set pushing branch if specified, otherwise...
if [ -n "$branch" ]; then
	if ! __branch_exists_local "$branch"; then
		echo ${E}"  The branch \`${1}\` does not exist locally! Aborting...  "${X}
		exit 1
	fi
# ...grab current branch and validate
else
	cb=$(__parse_git_branch)
	[ $cb ] && { branch="$cb"; } || {
		echo ${E}"  Could not determine current branch!  "${X}
		exit 1
	}
fi
# check for protected branches
if __is_branch_protected --push "$branch" && [ ! $isAdmin ]; then
	[ ! $isQuiet ] && echo "  ${W}WARNING:${X} Pushing to ${B}\`${branch}\`${X} is not allowed. Aborting..."
	exit 1
fi
# a remote is required to push to
if ! __set_remote; then
	echo ${E}"  Aborting...  "${X}
	exit 1
fi


# setup default answers
if [ "$pushanswer" == "y" ] || [ "$pushanswer" == "Y" ]; then
	defO=" (y) n"
	defA="y"
else
	defO=" y (n)"
	defA="n"
fi

echo ${Q}"Would you like to push ${B}\`${branch}\`${Q} to ${COL_GREEN}${_remote}${Q}?${defO}"${X}
read yn

if [ -z "$yn" ]; then
	yn=$defA
fi

echo
if [ "$yn" == "y" ] || [ "$yn" == "Y" ]; then
	if [ -n "$_remote" ]; then
		echo
		echo "Now pushing to:${X} ${COL_GREEN} ${_remote} ${X}"
		echo ${O}${H2HL}
		echo "$ git push ${_remote} ${branch}"
		git push "${_remote}" "${branch}"
		echo ${O}${H2HL}${X}
		echo
	else
		echo ${E}"  No remote could be found. Push aborted.  "${X}
		exit 1
	fi
fi

exit
