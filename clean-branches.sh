#!/bin/bash

## /*
#	@usage clean-branches
#
#	@description
#	This script iterates through your local branches and prompts you to delete branche that are fully merged into master.
#	description@
#
#	@notes
#	- You will end on the same branch you started out on.
#	notes@
#
#	@examples
#	1) clean-branches
#	examples@
#
#	@dependencies
#	gitscripts/gsfunctions.sh
#	dependencies@
## */
$loadfuncs

startingBranch=$(__parse_git_branch)
if [ -z "$startingBranch" ]; then
	echo ${E}"Unable to determine current branch."${X}
	exit 1
fi

echo
echo
echo


echo ${H1}
echo ${H1HL}
echo "Clean Branches"
echo ${H1HL}
echo "This script iterates through your local branches and prompts you to delete branche that are fully merged into master, prompting you to delete the ones that are."
echo ${X}
echo
echo
echo

# ${gitscripts_path}checkout.sh master

for branch in `git branch`
do
	wellformed=`git branch | grep "${branch}"`
	if [ -n "$wellformed" ]
		then
		masterContains=`git branch --contains "${branch}" | grep "master"`
		if [ -n "$masterContains" ]
			then
			if [ "$branch" != "master" ]
				then

				echo ${H2}${H2HL}
				echo "${STYLE_NEWBRANCH_H2}\`${branch}\`${H2}  appears to be merged into the following branches:"
				echo ${H2HL}${X}
				echo
				# git branch --contains "${branch}"

				# echo "git branch --contains \"${branch}\""

				# branchesContainingThisOne=`git branch --no-color --contains "${branch}"` | awk '{gsub(/\* /, "");print;}'
				branchesContainingThisOne=`git branch --no-color --contains "${branch}" | awk '{gsub(/\* /, "");print;}'`
				# branchesContainingThisOne=`git branch --no-color --contains "${branch}"` | awk '{gsub(/\* /, "");print;}'



				echo ${O}${H2HL}

				for aBranch in $branchesContainingThisOne
				do

					# echo "aBranch: \"${aBranch}\""
					# echo "git branch | grep \"${aBranch}\""
					wellformed=`git branch | grep "${aBranch}"`
					# echo "wellformed: ${wellformed}"

					if [ -n "$wellformed" ]
						then
						branchcontains=`git branch --contains "${branch}" | grep "${aBranch}"`
						if [ -n "$branchcontains" ]
							then
							echo "${aBranch}"
							# echo "${COL_RED}$aBranch${COL_NORM}"
						fi
					fi
				done
				echo ${H2HL}

				echo ${STYLE_INPUT}
				echo "  delete $branch? (y) n"
				echo ${X}
				read decision
				if [ -z $decision ] || [ "$decision" = "y" ]
					then
					echo "git branch -d $branch"
					${gitscripts_path}delete.sh $branch
				fi
			fi
		fi
	fi
done

git checkout $startingBranch