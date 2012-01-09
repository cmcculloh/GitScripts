#!/bin/bash
# merge
# merges one git branch into another
$loadfuncs


# check for minimum requirements
[ $# -eq 1] && oneArg=true
[ $# -eq 3] && threeArg=true

# must have 1 arg (merge $1 into current branch) or 3 (merge $1 into $2)
if [ ! $oneArg ] && [ ! threeArg ]; then
	echo
	echo __bad_usage merge "Invalid number of parameters."
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
echo ${H1}${H1HL}
echo "Merging from \`${COL_MAG}$mergeBranch${COL_NORM}\` into \`${COL_MAG}$baseBranch${COL_NORM}\`"
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

if [ "$current_branch" == "$baseBranch" ]; then
	# make sure current branch is clean
	if __parse_git_status clean; then
		if __parse_git_status behind; then
			# pull in updates
			remote=__get_remote
			if [ -n "$remote" ]; then
				echo "Now pulling in changes from the remote..."
				echo ${O}${H2HL}
				echo "$ git pull"
			fi
		fi
	fi
else
	echo "This checks out the \`$1\` branch..."
	echo "$ checkout $1"
	${gitscripts_path}checkout.sh $3
fi
echo
echo
echo "This checks out the \`$3\` branch..."
echo "$ checkout $3"
${gitscripts_path}checkout.sh $3
result=$?

if [ $result -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "git checkout $3 failed"
	return -1
elif [ $result -eq 255 ]
	then
	echo "Checking out the branch $3 was unsuccessful, aborting merge attempt..."
	return -1
fi

echo
echo
echo This merges from $1 into $3
echo git merge --no-ff $1
git merge --no-ff $1

if [ $? -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "git merge --no-ff $1 failed"
	return -1
fi

statusofmerge=`git status | grep "Unmerged paths"`

if [[ "$statusofmerge" == "# Unmerged paths:" ]];
	then
		echo
		git status
		echo

		echo
		echo "${COL_YELLOW}WARNING: You have unmerged paths!${COL_NORM}"
		echo
		echo "Please ${COL_RED}resolve your merge conflicts${COL_NORM} , then ${COL_YELLOW}run a build and test your build before pushing${COL_NORM} back out.${STYLE_NORM}"
		echo
		echo "Would you like to run the merge tool? (y) n"
		read YorN
		if [ "$YorN" != "n" ]
			then

				git mergetool
			else
				return -1
		fi
fi

statusofmerge=`git status | grep "Changes to be committed"`

if [[ "$statusofmerge" == "# Changes to be committed:" ]];
	then
		echo
		git status
		echo

		echo "${COL_YELLOW}WARNING: You have uncommitted changes!${COL_NORM}"
		echo
		echo "Please ${COL_RED}add/commit${COL_NORM} any changes you have.${STYLE_NORM}"
		echo "Would you like to commit these changes? (y) n"
		read YorN
		if [ "$YorN" != "n" ]
			then
				echo "please enter a commit message"
				read commitmessage

				source ${gitscripts_path}commit.sh "$commitmessage" -a

			else
				return -1
		fi
fi

echo
echo
echo git status
git status
echo
echo "Would you like to push? y (n)"
read YorN
if [ "$YorN" = "y" ]
	then
	remote=$(git remote)
	git push $remote head

	#offer to delete dev/dev2/qa for them if they push since they may no longer need it
	if [ -n "$branchprotected_nomergefrom" ]
	then
		if [ "$3" != "$current_branch" ]
			then
			echo
			echo
			echo "Would you like to delete ${COL_CYAN}$3${COL_NORM} and check ${COL_CYAN}$current_branch${COL_NORM} back out? y (n)"
			read decision
			if [ "$decision" = "y" ]
				then
				echo
				echo
				echo "checking out ${COL_CYAN}$current_branch${COL_NORM}"
				${gitscripts_path}checkout.sh $current_branch

				echo
				echo
				echo "deleting ${COL_CYAN}$3${COL_NORM}"
				${gitscripts_path}delete.sh $3
			fi
		fi
	fi
else
	if [ "$3" != "$current_branch" ]
		then
		echo
		echo
		echo "Would you like to check ${COL_CYAN}$current_branch${COL_NORM} back out? y (n)"
		read decision
		if [ "$decision" = "y" ]
			then
			echo
			echo
			echo "checking out ${COL_CYAN}$current_branch${COL_NORM}"
			${gitscripts_path}checkout.sh $current_branch
		fi
	fi
fi

if [ $? -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "git push ${COL_CYAN}$remote $3${COL_NORM} failed"
	return -1
fi



