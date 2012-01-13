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
if [ ! $ignoreprotect ] && __is_protected_branch --merge-from "$mergeBranch"; then
	echo "  ${W}WARNING:${X} Merging ${COL_YELLOW}from${COL_NORM} ${B}\`$1\`${X} not allowed. Aborting..."
	exit 1
fi

if [ ! $ignoreprotect ] && __is_protected_branch --merge-to "$baseBranch"; then
	echo "  ${W}WARNING:${X} Merging ${COL_YELLOW}into${COL_NORM} ${B}\`$3\`${X} not allowed. Aborting..."
	exit 1
fi

# do the merge
echo
echo ${H1}${H1HL}
echo "  Beginning merge from ${B}\`${mergeBranch}\`${H1} into ${B}\`${baseBranch}\`${H1}  "
echo ${H1HL}${X}
echo
echo
echo "This tells your local git about all changes on the remote..."
echo ${O}${H2HL}
echo "$ git fetch --all --prune"
git fetch --all --prune
echo ${O}${H2HL}${X}
echo
echo
echo "This checks out the ${B}\`${mergeBranch}\`${X} branch..."
echo ${O}${H2HL}
echo "$ checkout ${mergeBranch}"
"${gitscripts_path}"checkout.sh "$mergeBranch"
echo ${X}
echo
echo "This checks out the ${B}\`${baseBranch}\`${X} branch..."
echo ${O}${H2HL}
echo "$ checkout $baseBranch"
"${gitscripts_path}"checkout.sh "$baseBranch"
echo ${X}
echo
echo "This merges from ${B}\`${mergeBranch}\`${X} into ${B}\`${baseBranch}\`${X}..."
echo ${O}${H2HL}
echo "$ git merge --no-ff ${mergeBranch}"
git merge --no-ff $mergeBranch

# check for merge conflicts
if git status | grep -q "Unmerged paths"; then
	echo ${O}
	echo
	echo "$ git status"
	git status
	echo ${O}${H2HL}${X}
	echo
	echo
	echo "${W}WARNING:${X} You have unmerged paths!"
	echo
	echo "Please ${A}resolve your merge conflicts${X}, then ${A}run a build and test your build before pushing${X} back out."
	echo
	echo ${Q}"Would you like to run the merge tool? (y) n"${X}
	read yn
	if [ -z "$yn" ] || [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
		git mergetool
	else
		exit
	fi
fi


echo ${O}
echo
echo "$ git status"
git status
echo ${O}${H2HL}${X}
echo
echo

# wrapping up...
__is_protected_branch --push "$startingBranch" && isProtected=true
if [ $isProtected ] && [ ! $isAdmin ]; then
	echo ${E}"  The branch \`${startingBranch}\` is protected and cannot be pushed. Aborting...  "${X}
elif [ ! $isProtected ] || [ $isAdmin ]; then
	"${gitscripts_path}"push.sh "$baseBranch"
fi

# user may wish to return to original branch
if [ "$current_branch" != "$baseBranch" ]; then
	echo
	echo
	echo ${Q}"Would you like to check ${B}\`${current_branch}\`${Q} back out? y (n)"${X}
	read decision
	if [ "$decision" = "y" ] || [ "$decision" = "Y" ]; then
		echo
		echo "Checking out ${B}\`${current_branch}\`${X}..."
		echo "$ checkout ${current_branch}"
		"${gitscripts_path}"checkout.sh "$current_branch"
		# checkout does not prompt for clearing screen so we can include it at the end
	fi
fi

"${gitscripts_path}"clear-screen.sh

exit
