#!/bin/bash
# contains
# checks to see which other branches the branch you specify has merged into it

branchtocheck=$1
if [ -z "$branchtocheck" ]; then
	#use current branch if none specified
	$loadfuncs
	branchtocheck=$(__parse_git_branch)
fi

echo
echo ${H2}${H1HL}
echo "Running contains on: $branchtocheck  "
echo ${H1HL}
echo ${X}
echo

echo "The following branches contain the lateset version of ${COL_CYAN}$branchtocheck${COL_NORM}"
git branch --contains $branchtocheck

echo
echo
echo "the following branches ${COL_CYAN}do not${COL_NORM} contain the latest version of ${COL_CYAN}$branchtocheck${COL_NORM}"
echo ${H2HL}
allbranches=`git branch`
for branch in $allbranches
do
	wellformed=`git branch | grep "${branch}"`
	if [ -n "$wellformed" ]
		then
		branchcontains=`git branch --contains ${branchtocheck} | grep "${branch}"`
		if [ -z "$branchcontains" ]
			then
			echo "${COL_RED}$branch${COL_NORM}"
		fi
	fi
done
echo ${H2HL}

