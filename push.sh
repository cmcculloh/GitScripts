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
#	--tags ALSO pushes tags to remote
#	options@
#
#	@examples
#	1) push
#	   # pushes current branch
#	2) push some-other-branch
#	   # pushes some-other-branch...
#	3) push --tags
#	   # pushes current branch -AND- pushes any tags
#	examples@
#
#	@dependencies
#	functions/5000.branch_exists_local.sh
#	functions/5000.parse_git_branch.sh
#	functions/5000.set_remote.sh
#	dependencies@
#
#	@file push.sh
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
		[ "$1" = "--tags" ] && pushTags=true
		! echo "$1" | egrep -q "^-" && branch="$1"
		shift 1
	done
fi

# setup FAILURE conditions
# set pushing branch if specified, otherwise...
if [ -n "$branch" ]; then
	if ! __branch_exists_local "$branch"; then
		echo ${E}"  The branch \`${branch}\` does not exist locally! Aborting...  "${X}
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

# --quiet will use default answer
if [ ! $isQuiet ]; then
	echo ${Q}"Would you like to push ${B}\`${branch}\`${Q} to ${COL_GREEN}${_remote}${Q}?${defO}"${X}
	read yn
fi

if [ -z "$yn" ]; then
	yn=$defA
fi

echo
if [ "$yn" == "y" ] || [ "$yn" == "Y" ]; then
	if [ -n "$_remote" ]; then
		echo
		echo "Now ${A}pushing${X} to:${X} ${COL_GREEN} ${_remote} ${X}"
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

if [ $pushTags ]; then
	echo
	echo "Now ${A}pushing${X} tags to: ${COL_GREEN} ${_remote} ${X}"
	echo "$ git push --tags ${_remote}"
	git push --tags ${_remote}
	echo ${O}${H2HL}${X}
fi

hasRemote=$(git config branch.$branch.remote 2> /dev/null)
if [ -z "$hasRemote" ]; then
	echo
	echo ${Q}"Setup remote tracking of ${COL_GREEN}${_remote}${Q} for ${B}\`${branch}\`${Q}? (y) n"
	read yn
	if [ -z "$yn" ] || [ "$yn" = "y" ]; then
		git branch --set-upstream-to $_remote/$branch $branch
	fi
fi

exit
