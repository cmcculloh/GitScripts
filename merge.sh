#!/bin/bash
## /*
#	@usage merge [<branch_name> [into <branch_name2>]]
#
#	@description
#	This script is a helpful wrapper for merging one branch into another.
#
#	If you have merge conflicts and you want to resolve them, running this command will get that
#	started as long as you have your mergetool configured [TODO: Add documentation or link to
#	documentation. For now, here is a link that I have not read the contents of, but this might
#	get you started: http://www.davesquared.net/2009/02/setting-up-diff-and-merge-tools-for-git.html]
#
#	If you are trying to initiate a merge of two branches, this script will do that too. The command
#	is more intuitive (than "git merge") because it uses "into" to clearly distinguish merge direction.
#
#	There are some helpful safeties included as well. Referenced branches
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
#	1) merge                             # Runs your pre-configured merge tool (because McCulloh can't remember how to make it run otherwise)
#	2) merge master                     # Merges master into current branch
#	3) merge my-branch into master      # Merges my-branch into master (unless master is a protected branch)
#	4) merge my-branch another-branch   # This will fail. The second "action" parameter (into) must be included.
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
[ $# -eq 0 ] && runmergetool=true
[ $# -eq 1 ] && oneArg=true
[ $# -eq 2 ] && [ "$2" = "--admin" ] && [ $ADMIN ] && oneArg=true && isAdmin=true
[ $# -eq 3 ] && threeArg=true
[ $# -eq 4 ] && [ "$4" = "--admin" ] && [ $ADMIN ] && threeArg=true && isAdmin=true

# McCulloh just wants to run the merge tool
if [ $runmergetool ]; then
	echo "Run merge tool? (y) n"
	read yn
	if [  -z "$yn" ] || [ "$yn" = "y" ]; then
		git mergetool
	else
		__bad_usage merge "Invalid number of parameters."
	fi

	exit 1
fi


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
if [ ! $isAdmin ] && __is_branch_protected --merge-from "$mergeBranch"; then
	echo "  ${W}WARNING:${X} Merging ${COL_YELLOW}from${COL_NORM} ${B}\`$1\`${X} not allowed. Aborting..."
	exit 1
fi

if [ ! $isAdmin ] && __is_branch_protected --merge-to "$baseBranch"; then
	echo "  ${W}WARNING:${X} Merging ${COL_YELLOW}into${COL_NORM} ${B}\`$3\`${X} not allowed. Aborting..."
	exit 1
fi

# do the merge
echo
echo ${H1}${H1HL}
echo "  Beginning merge from ${H1B}\`${mergeBranch}\`${H1} into ${H1B}\`${baseBranch}\`${H1}  "
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
if [ $isAdmin ]; then
	"${gitscripts_path}"push.sh --admin "$baseBranch"
else
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
