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
#	gitscripts/gsfunctions.sh
#	dependencies@
## */
$loadfuncs


cb=$(__parse_git_branch)
remote=$(__get_remote)

echo
if git branch -r | grep -q $cb; then
	echo ${H1}${H1HL}
	echo " Pulling in changes from ${STYLE_OLDBRANCH_H1}\`${remote}/${cb}\`${H1} "
	echo ${H1HL}${X}
	echo
	echo
	echo ${O}${H2HL}
	echo "$ git pull ${remote} ${cb}"
	git pull $remote $cb
	echo ${H2HL}${X}
else
	echo ${E}"  The current branch \`${cb}\` does not exist on the remote. Aborting...  "
	exit 1
fi

exit
