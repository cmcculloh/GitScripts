#!/bin/bash
## /*
#	@usage pull [branch-name] [-q, --quiet]
#
#	@description
#	This is a quick script that pulls in changes from the current branch's remote
#	tracking branch if it exists. User can also specify another branch to pull
#	in changes from. Pull branch is verified to exist on the remote first. If
#	it doesn't, the script is aborted.
#	description@
#
#	@dependencies
#	functions/5000.branch_exists.sh
#	functions/5000.parse_git_branch.sh
#	functions/5000.set_remote.sh
#	dependencies@
#
#	@file pull.sh
## */
$loadfuncs

# parse params
numArgs=$#
if (( numArgs > 0 && numArgs < 3 )); then
	until [ -z "$1" ]; do
		{ [ "$1" = "-q" ] ||  [ "$1" = "--quiet" ]; } && isQuiet=true
		! echo "$1" | egrep -q "^-" && branch="$1"
		shift 1
	done
fi


cb=$(__parse_git_branch)
pullBranch="$cb"

echo ${X}
echo ${O}"Configuring remote(s), if any... "${X}
__set_remote
echo
echo

if [ ! $_remote ]; then
	echo ${E}"  There is no remote to pull in changes from! Aborting...  "${X}
	exit 1
fi


# if user specified a branch, fetch and pull it in.
if [ -n "$branch" ]; then
	__branch_exists_remote "$branch" && { pullBranch="$branch"; } || {
		echo ${E}"  The branch \`$branch\` does not exist on the remote! Aborting...  "${X}
		exit 1
	}
fi

# give the user an opportunity to abort if no -q or --quiet flag passed
if [ ! $isQuiet ]; then
	echo ${Q}"Are you sure you want to ${A}pull${Q} changes from ${STYLE_NEWBRANCH}\`${_remote}/${pullBranch}\`${Q} into ${STYLE_OLDBRANCH}\`${cb}\`${Q}? (y) n"
	read yn
	echo
	if [ -n "$yn" ] && [ "$yn" != "y" ] && [ "$yn" != "Y" ]; then
		echo "Better safe than sorry! Aborting..."
		exit 0
	fi
fi

echo ${H1}${H1HL}
echo "  Pulling in changes from ${H1B}\`${_remote}/${pullBranch}\`${H1}  "
echo ${H1HL}${X}
echo
echo
echo "${A}Fetching${X} updated changes from ${COL_GREEN}${_remote}${X} and ${A}pulling${X} them into ${B}\`${cb}\`${X}..."
echo ${O}${H2HL}
echo "$ git fetch --all --prune"
git fetch --all --prune
echo
echo
echo ${O}"$ git pull ${_remote} ${pullBranch}"
git pull "$_remote" "$pullBranch"
echo ${O}${H2HL}${X}


exit
