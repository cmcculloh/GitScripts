#!/bin/bash
# merge
# merges one git branch into another
$loadfuncs


# check for minimum requirements
[ $# -eq 1 ] && oneArg=true
[ $# -eq 3 ] && threeArg=true
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
if [ $isProtectedFrom ]; then
	echo "  ${COL_RED}WARNING:${COL_NORM} Merging ${COL_YELLOW}from${COL_NORM} ${COL_CYAN}$1${COL_NORM} not allowed. Aborting..."
	exit 1
fi

[ -z "${protectmergeto_path}" ] || isProtectedTo=`grep "$baseBranch" ${protectmergeto_path}`
if [ $isProtectedTo ]; then
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
if [ -z "$yn" ] || [ "$yn" = "n" ] || [ "$yn" = "N" ]; then
	remote=$(__get_remote)
	echo ${O}${H2HL}
	echo "$ git push ${remote} ${baseBranch}"
	git push $remote $baseBranch
	echo ${H2HL}${X}
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
	fi
fi

exit
