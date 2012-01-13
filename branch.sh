#!/bin/bash
## /*
#	@usage branch [options] [search-string]
#
#	@description
#	This is a handy tool to filter local and/or remote branch names in your repository.
#	It shows all branches as a menu and allows you to choose the branch by index.
#	Default behavior is to show BOTH local and remote branches. To filter further, use
#	one of the options below
#	description@
#
#	@options
#	-c, --checkout  Prompt user to checkout branch after selecting it.
#	-l, --local     Show only local branches.
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
#	functions/0300.menu.sh
#	dependencies@
## */
$loadfuncs

echo ${X}

# parse params
numArgs=$#
if (( numArgs > 0 && numArgs < 3 )); then
	until [ -z "$1" ]; do
		{ [ "$1" = "-l" ] || [ "$1" = "--local" ]; } && getLocal=true
		{ [ "$1" = "-r" ] || [ "$1" = "--remote" ]; } && getRemote=true
		! echo "$1" | egrep -q "^-" && search="$1"
		shift
	done

	flag="-a"
	if [ $getLocal ] && [ ! $getRemote ]; then
		flag=""
	elif [ $getRemote ] && [ ! $getLocal ]; then
		flag="-r"
	fi
fi

# grab and parse meta from branches
branches=$(git branch $flag | grep "$search" | sed 's/*/ /' | sed 's/remotes\///' | awk '{ if ($0 !~ /.+ -> .+/) print; }');

# generate menu
[ -n "$branches" ] && __menu "$branches" || {
	echo ${O}"No branches found!"${X}
	exit 1
}

# process selection
if [ $_menu_selection ]; then
	# gather remotes to remove the name from the branch before checking it out
	remotes=$(git remote)
	branch="$_menu_selection"
	for remote in $remotes; do
		branch=$(echo "$branch" | sed "s/${remote}\///")
	done

	echo
	echo ${Q}"  Checkout ${B}\`${branch}\`${Q}? y (n)  "${X}
	read yn
	if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
		echo
		"${gitscripts_path}"checkout.sh "$branch"
	fi
fi

exit
