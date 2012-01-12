## /*
#	@usage __is_branch_protected <keyword> <branch-name>
#
#	@description
#
#	description@
#
#	@notes
#	-
#	notes@
#
#	@examples
#	1)
#	examples@
#
#	@dependencies
#	gitscripts/path/to/file
#	dependencies@
## */

function __is_branch_protected {
	if [ $# -ne 2 ]; then
		echo ${E}"  __is_branch_protected: Must have 2 parameters (keyword and branch-name).  "${X}

		# return success so that the default behavior is that the branch IS protected
		exit 0
	fi


}