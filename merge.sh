#!/bin/bash
## /*
#	@usage merge <branch_name> [into <branch_name2>]
#
#	@description
#	This script is a helpful wrapper for merging one branch into another. The command itself
#	is more intuitive because it uses "into" to clearly distinguish which branch is getting
#	merged into the other.  There are some helpful safeties included as well. Referenced branches
#	are checked for existence before the script gets too far along, protected branches are checked,
#	and merge conflicts are determined after the merge. If merge conflicts should arise, the
#	user is prompted to resolve them using the native git mergetool.
#	description@
#
#	@notes
#	- If specifying both branches in the merge, the second parameter (which should be "into") is
#	not explicitly checked. Technically, a user could successfully merge two branches with the
#	command "merge branch1 flapjack branch2".
#	notes@
#
#	@examples
#	1) merge master                     # Merges master into current branch
#	2) merge my-branch into master      # Merges my-branch into master (unless master is a protected branch)
#	3) merge my-branch another-branch   # This will fail. The second "action" parameter (into) must be included.
#	examples@
#
#	@dependencies
#	checkout.sh
#	clear-screen.sh
#	functions/0100.bad_usage.sh
#	functions/5000.branch_exists.sh
#	functions/5000.parse_git_branch.sh
#	functions/5000.set_remote.sh
#	dependencies@
## */
$loadfuncs


# check for minimum requirements

[ $# -eq 1 ] && oneArg=true
[ $# -eq 2 ] && [ "$2" = "--admin" ] && [ $ADMIN ] && oneArg=true && ignoreprotect=true
[ $# -eq 3 ] && threeArg=true
[ $# -eq 4 ] && [ "$4" = "--admin" ] && [ $ADMIN ] && threeArg=true && ignoreprotect=true
# must have 1 arg (merge $1 into current branch) or 3 (merge $1 into $2)
if [ ! $oneArg ] && [ ! $threeArg ]; then
	echo
	__bad_usage merge "Invalid number of parameters."
	exit 1

# branch getting merged in (first param) must exist
elif ! __branch_exists $1; then
	echo
	echo ${E}"  Branch \`$1\` does not exist! Aborting...  "
	exit 1
fi

# if three params given, make sure base branch (3rd param) exists (first branch was just checked above).
# this not included as an elif because we want this check done in addition to previous check.
if [ $threeArg ] && ! __branch_exists $3; then
	echo
	echo ${E}"  Branch \`$3\` does not exist! Aborting...  "
	exit 1
fi

current_branch=$(__parse_git_branch)
mergeBranch=$1
[ $oneArg ] && { baseBranch=$current_branch; } || { baseBranch=$3; }

# check protected branches
[ -z "${protectmergefrom_path}" ] || isProtectedFrom=`grep "$mergeBranch" ${protectmergefrom_path}`
if [ ! $ignoreprotect ] && [ $isProtectedFrom ]; then
	echo "  ${COL_RED}WARNING:${COL_NORM} Merging ${COL_YELLOW}from${COL_NORM} ${COL_CYAN}$1${COL_NORM} not allowed. Aborting..."
	exit 1
fi

[ -z "${protectmergeto_path}" ] || isProtectedTo=`grep "$baseBranch" ${protectmergeto_path}`
if [ ! $ignoreprotect ] && [ $isProtectedTo ]; then
	echo "${COL_RED}WARNING:${COL_NORM} merging ${COL_YELLOW}into${COL_NORM} ${COL_CYAN}$3${COL_NORM} not allowed."
	exit 1
fi

# do the merge
echo
echo ${H1}${H1HL}
echo "Beginning merge from \`${COL_MAG}${mergeBranch}${COL_NORM}\` into \`${COL_MAG}${baseBranch}${COL_NORM}\`  "
echo ${H1HL}${X}
echo
echo
echo "This tells your local git about all changes on the remote..."
echo ${O}${H2HL}
echo "$ git fetch --all --prune"
git fetch --all --prune
echo ${H2HL}${X}
echo
echo
echo "This checks out the \`${mergeBranch}\` branch..."
echo ${O}${H2HL}
echo "$ checkout $mergeBranch"
${gitscripts_path}checkout.sh $mergeBranch
echo
echo
echo "This checks out the \`${baseBranch}\` branch..."
echo ${O}${H2HL}
echo "$ checkout $baseBranch"
${gitscripts_path}checkout.sh $baseBranch
echo
echo
echo "This merges from ${mergeBranch} into ${baseBranch}..."
echo ${O}${H2HL}
echo "$ git merge --no-ff ${mergeBranch}"
git merge --no-ff $mergeBranch

# check for merge conflicts
if git status | grep -q "Unmerged paths"; then
	echo
	echo
	echo "$ git status"
	git status
	echo ${H2HL}${X}
	echo
	echo
	echo "${COL_YELLOW}WARNING: You have unmerged paths!${COL_NORM}"
	echo
	echo "Please ${COL_MAG}resolve your merge conflicts${COL_NORM}, then ${COL_MAG}run a build and test your build before pushing${COL_NORM} back out."
	echo
	echo "Would you like to run the merge tool? (y) n"
	read yn
	if [ -z "$yn" ] || [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
		git mergetool
	else
		exit
	fi
fi


echo
echo ${O}
echo "$ git status"
git status
echo ${H2HL}${X}
echo
echo
echo ${I}"Would you like to push? y (n)"${X}
read yn
if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
	__set_remote
	if [ $_remote ]; then
		echo ${O}${H2HL}
		echo "$ git push ${_remote} ${baseBranch}"
		git push $_remote $baseBranch
		echo ${H2HL}${X}
	else
		echo ${E}"  No remote could be found. Push aborted.  "${X}
	fi
fi

if [ "$current_branch" != "$baseBranch" ]; then
	echo
	echo
	echo ${I}"Would you like to check \`${COL_CYAN}${current_branch}${COL_NORM}\` back out? y (n)"${X}
	read decision
	if [ "$decision" = "y" ] || [ "$decision" = "Y" ]; then
		echo
		echo "Checking out \`${COL_CYAN}${current_branch}${COL_NORM}\`..."
		echo "$ checkout ${current_branch}"
		${gitscripts_path}checkout.sh $current_branch
	else
		"${gitscripts_path}clear-screen.sh"
	fi
else
	"${gitscripts_path}clear-screen.sh"
fi

exit
