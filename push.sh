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
#	@notes
#	-
#	notes@
#
#	@examples
#	1) push
#	   # pushes current branch
#	2) push some-other-branch
#	   # pushes some-other-branch...
#	examples@
#
#	@dependencies
#	functions/5000.branch_exists_locally.sh
#	functions/5000.parse_git_branch.sh
#	functions/5000.set_remote.sh
#	dependencies@
## */
$loadfuncs


# reset styles
echo ${X}

# set pushing branch if specified, otherwise...
if [ -n "$1" ] && __branch_exists_local "$1"; then
	cb="$1"

# ...grab current branch and validate
else
	cb=$(__parse_git_branch)
	[ $cb ] || {
		echo ${E}"  Could not determine current branch!  "${X}
		exit 1
	}
fi

if ! __set_remote; then
	echo ${E}"  Aborting...  "${X}
	exit 1
fi

echo ${Q}"Would you like to push ${STYLE_NEWBRANCH}\`${cb}\`${Q} to ${COL_GREEN}${_remote}${Q}? y (n)"${X}
read YorN
echo
if [ "$YorN" == "y" ] || [ "$YorN" == "Y" ]; then
	if [ -n "$_remote" ]; then
		echo
		echo "Now pushing to:${X} ${COL_GREEN} ${_remote} ${X}"
		echo ${O}${H2HL}
		echo "$ git push ${_remote} ${cb}"
		git push "${_remote}" "${cb}"
		echo ${O}${H2HL}${X}
		echo
	else
		echo ${E}"  No remote could be found. Push aborted.  "${X}
		echo
		exit 1
	fi
fi

exit
