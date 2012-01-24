## /* @function
#	@usage __branch_merge_set <branch_name>
#
#	@output false
#
#	@description
#	Determine if the given branch exists either locally or remotely. If it exists locally,
#	skip checking for the remote branch.
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
#	if __branch_merge_set my-branch; then
#		echo "Branch my-branch's config set correctly."
#	fi
#
#	#...
#	examples@
#
#	@dependencies
#	functions/0200.gslog.sh
#	dependencies@
#
#	@file functions/5000.branch_merge_set.sh
## */
function __branch_merge_set {
	if [ -z "$1" ]; then
		__gslog "__branch_merge_set: First parameter must be branch name."
		return 1
	fi

	local configExists=$(git config --get branch.$1.merge)
	if [ -n "$configExists" ]; then
		return 0
	else
		return 1
	fi
}
