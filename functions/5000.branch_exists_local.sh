## /* @function
#	@usage __branch_exists_local <branch_name>
#
#	@output on error
#
#	@description
#	Determine if the given branch exists locally.
#	description@
#
#	@notes
#	- Since this function does not echo anything to be captured, it is most useful if
#	used directly in conditional statements. See example below.
#	notes@
#
#	@examples
#	# ...
#
#	if __branch_exists_local master; then
#		echo "local branch 'master' exists!"
#	fi
#
#	#...
#	examples@
#
#	@file functions/5000.branch_exists_local.sh
## */
function __branch_exists_local {
	if [ -z "$1" ]; then
		echo ${E}"  __branch_exists_local: First parameter must be branch name. Nothing given.  "${X}
		return 1
	fi

	git branch | egrep -q "^ *$1$" 2>/dev/null
}
