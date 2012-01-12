#!/bin/bash
## /*
#	@usage pull
#
#	@description
#	This is a quick script that pulls in changes from the current branch's remote
#	tracking branch if it exists. It will abort otherwise.
#	description@
#
#	@dependencies
#	functions/5000.parse_git_branch.sh
#	functions/5000.set_remote.sh
#	dependencies@
## */
$loadfuncs


cb=$(__parse_git_branch)
__set_remote

echo
if [ $cb ] && git branch -r | grep -q $cb; then
	if [ $_remote ]; then
		echo ${H1}${H1HL}
		echo " Pulling in changes from ${STYLE_OLDBRANCH_H1}\`${remote}/${cb}\`${H1} "
		echo ${H1HL}${X}
		echo
		echo
		echo ${O}${H2HL}
		echo "$ git pull ${remote} ${cb}"
		git pull "$remote" "$cb"
		echo ${H2HL}${X}
	else
		echo ${E}"  There is no remote configured to pull from. Aborting...  "${X}
		exit 1
	fi
else
	echo ${E}"  The current branch \`${cb}\` does not exist on the remote. Aborting...  "
	exit 1
fi

exit
