#!/bin/bash
## /*
#	@usage clean-branches
#
#	@description
#	This script iterates through your local branches and prompts you to delete
#	branches that are fully merged into master.
#	description@
#
#	@notes
#	- You will end on the same branch you started out on.
#	- To see which branches are already merged into the branch you’re on, you
#	  can run git branch --merged.
#	- To see all the branches that contain work you haven’t yet merged in, you
#	  can run git branch --no-merged.
#	notes@
#
#	@dependencies
#	checkout.sh
#	*delete.sh
#	functions/5000.parse_git_branch.sh
#	dependencies@
#
#	@file clean-branches.sh
## */
$loadfuncs


# parse args
if [ $# -lt 3 ]; then
	until [ -z "$1" ]; do
		[ "$1" == "--admin" ] && [ $ADMIN ] && aFlag="--admin"
		[ "$1" != "--admin" ] && target="$1"
		shift
	done
else
	__bad_usage clean-branches "Invalid number of parameters."
	exit 1
fi
[ -z "$target" ] && target="master"

# not being returned to the current branch is not crucial, it's only a convenience...
cb=$(__parse_git_branch)
if [ -z "$cb" ]; then
	echo ${W}"  Unable to determine current branch. You will not be returned to your"
	echo "  current branch after script completion.  "${X}
	echo
	echo ${Q}"  Would you like to continue anyway? y (n)"${X}
	read yn
	if [ "$yn" != "y" ] && [ "$yn" != "Y" ]; then
		echo
		echo "Aye, aye, cap'n! Aborting..."
		exit 1
	fi
fi


#delete branches fully merged into $target

echo ${X}
echo ${H1}${H1HL}
echo "  Clean-Branches will iterate through your local branches and prompt you to  "
echo "  delete branches that are merged into ${H1B}\`${target}\`${H1}.  "
echo ${H1HL}${X}
echo
echo

# if [ "$cb" != "$target" ]; then
# 	"${gitscripts_path}"checkout.sh "$target"
# fi

# git branch -v --abbrev=7 --merged "$target" | awk '$0 !~ /'$target'/ { gsub(/^\* /,""); print; }' | while read bLine; do
# 	pieces=( $bLine )
# 	echo ${COL_MAGENTA}${pieces[1]}${COL_NORM}" :: "${B}${pieces[0]}${X}
# done
# git branch --merged "$target"

targetHash=$(git show --oneline "$target")
targetHash="${targetHash%% *}"
echo "${B}\`${target}\`${X} Hash: ${STYLE_BRIGHT}${COL_MAGENTA}${targetHash}"${X}
echo

# a piped while loop was the only way to get the entire line of the git branch
# output in each iteration of the loop in an easily-parsable form. unfortunately,
# the loop runs in a subshell preventing variable data from being exported. to
# circumvent this problem, we can use I/O redirection
tmp="${gitscripts_temp_path}vbranch"
# set stdin to new file descriptor
# exec 3<&0

# send data to new file descriptor
git branch -v | awk '{gsub(/^\* /, "");print;}' > $tmp

# run loop. "read" reads from redirected stdin.
declare -a branchNames
declare -a branchHashes
while read branch; do
	pieces=( $branch )
	if git branch --contains "${pieces[1]}" | egrep -q "${target}"; then

		[ "$targetHash" = "${pieces[1]}" ] && {
			op="${STYLE_BRIGHT}=="
			bHash="${STYLE_BRIGHT}${pieces[1]}"
		} || {
			op=">>"
			bHash="${pieces[1]}"
		}

		branchNames[${#branchNames[@]}]="${pieces[0]}"
		branchHashes[${#branchHashes[@]}]="${pieces[1]}"
		echo "${STYLE_BRIGHT}${COL_MAGENTA}${targetHash}${X} ${COL_YELLOW}${op}${X} ${COL_MAGENTA}${bHash}${X} :: ${B}${pieces[0]}"${X}
	fi
done <"$tmp"

# restore stdin and close temporary file descriptor
# exec 1>&3
# exec 3>&-

echo
echo ${Q}"Would you like to begin deleting ${#branchNames[@]} branches? y (n)"${X}
read yn
echo
if [ "$yn" != "y" ] && [ "$yn" != "Y" ]; then
	echo "  Right on. Exiting..."
	exit 0
fi

# let's get this party started...
echo "deleting ${#branchNames[@]} branches..."
for (( i = 0; i < ${#branchNames[@]}; i++ )); do
	"${gitscripts_path}"delete.sh $aFlag "${branchNames[$i]}"
done

exit
#git checkout $startingBranch
