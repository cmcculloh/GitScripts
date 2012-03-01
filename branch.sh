#!/bin/bash
## /*
#	@usage branch [options] [search-string]
#
#	@description
#	This is a handy tool to filter local and/or remote branch names in your repository.
#	It leverages the __get_branch function to let the user choose a branch. For more
#	information on that part of the process, @see functions/5000.get_branch.sh.
#	description@
#
#	@options
#	-l, --local     Show only local branches.
#	-q, --quiet     Do not show the informational message containing search query.
#	-r, --remote    Show only remote branches.
#	options@
#
#	@notes
#	- Search string CANNOT begin with a hyphen!
#	- Passing both options above will result in showing ALL branches as expected.
#	notes@
#
#	@examples
#	1) branch --local part-of-bran
#	   # filters local branches that match "part-of-bran"
#	2) branch -r
#	   # shows ALL remote branches
#	examples@
#
#	@dependencies
#	*checkout.sh
#	functions/5000.get_branch.sh
#	dependencies@
#
#	@file branch.sh
## */
$loadfuncs


echo ${X}

# send params through to __get_branch
__get_branch $@

# if no selection was made or no branch could be found, exit.
if [ ! $_branch_selection ]; then
	echo ${E}"  Unable to acquire a branch name. Aborting...  "${X}
	exit 1
fi












# setup default answers
if [ "$checkoutforbranchanswer" == "y" ] || [ "$checkoutforbranchanswer" == "Y" ]; then
	defO=" (y) n"
	defA="y"
else
	defO=" y (n)"
	defA="n"
fi

# --quiet will use default answer
if [ ! $isQuiet ]; then
	echo ${Q}"Would you like to ${A}checkout${X}${Q} the branch ${B}\`${_branch_selection}\`${X}${Q}?${defO}"${X}
	read yn
fi

if [ -z "$yn" ]; then
	yn=$defA
fi

echo

if [ "$yn" == "y" ] || [ "$yn" == "Y" ]; then
	echo
	echo "Will now ${A}checkout${X} ${B}\`${_branch_selection}\` ${X}"
	"${gitscripts_path}"checkout.sh "$_branch_selection"
fi








# prompt to checkout branch
# echo
# echo ${Q}"  ${A}Checkout${X} ${B}\`${_branch_selection}\`${Q}? y (n)  "${X}
# read yn
# if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
# 	echo
# 	"${gitscripts_path}"checkout.sh "$_branch_selection"
# fi


exit
