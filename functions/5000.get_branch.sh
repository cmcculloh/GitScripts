## /* @function
#	@usage __get_branch [options] [search-string]
#
#	@output true
#
#	@vars
#	$_branch_selection
#	vars@
#
#	@description
#	This is a handy tool to filter local and/or remote branch names in your repository.
#	If you pass this function a search string, it will search for branch names which
#	contain that string anywhere in the name (even in the remote name). It shows all
#	branches as a menu and allows you to choose the branch by index.
#
#	Default behavior is to show BOTH local and remote branches. To filter further, use
#	one of the filter options described below. After a selection is made, it is made available
#	in the variable $_branch_selection.
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
#	- Passing both -l and -r options above will result in showing ALL branches as expected.
#	notes@
#
#	@examples
#	1) __get_branch --local part-of-bran
#	   # filters local branches that match "part-of-bran" anywhere in the branch name
#	2) __get_branch -r
#	   # shows ALL remote branches
#	3) __get_branch -q
#	   # shows both local and remote branches without displaying informational message before
#	   # the menu is displayed
#	examples@
#
#	@dependencies
#	functions/0300.menu.sh
#	dependencies@
#
#	@file functions/5000.get_branch.sh
## */
function __get_branch {
	# declare local vars
	local flag
	local getLocal
	local getRemote
	local isQuiet
	local listType
	local numArgs
	local query

	# parse params
	numArgs=$#
	flag="-a"
	listType="local and remote"
	if (( numArgs > 0 && numArgs < 5 )); then
		until [ -z "$1" ]; do
			{ [ "$1" = "-l" ] || [ "$1" = "--local" ]; } && getLocal=true
			{ [ "$1" = "-r" ] || [ "$1" = "--remote" ]; } && getRemote=true
			{ [ "$1" = "-q" ] || [ "$1" = "--quiet" ]; } && isQuiet=true
			! echo "$1" | egrep -q "^-" && query="$1"
			shift
		done

		if [ $getLocal ] && [ ! $getRemote ]; then
			flag=
			listType="local"
		elif [ $getRemote ] && [ ! $getLocal ]; then
			flag="-r"
			listType="remote"
		fi
	fi

	# grab and parse meta from branches
	[ $query ] && [ ! $isQuiet ] && { echo "Searching ${O}${listType}${X} branches for branch names like: ${STYLE_BRIGHT}${COL_YELLOW}${query}"${X}; echo; }
	branchArr=( $(git branch $flag | grep "$query" | sed 's/*/ /' | sed 's/remotes\///' | awk '{ if ($0 !~ /.+ -> .+/) print; }') )

	# generate menu. the "no branches found" message only triggered if an invalid
	# selection is made from __menu or $branches is empty
	[ ${#branchArr[@]} -gt 0 ] && __menu ${branchArr[@]} || {
		echo ${W}"  No branches found!  "${X}
		return 1
	}

	# process selection and export variable
	[ $_menu_sel_value ] && {
		export _branch_selection="$_menu_sel_value"
		return 0
	} || {
		export _branch_selection=
		return 1
	}
}
