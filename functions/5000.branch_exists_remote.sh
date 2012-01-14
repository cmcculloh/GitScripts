## /* @function
#	@usage __branch_exists_remote <branch_name>
#
#	@output false
#
#	@description
#	Determine if the given branch exists on the remote.
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
#	if __branch_exists_remote master; then
#		echo "remote branch 'master' exists!"
#	fi
#
#	#...
#	examples@
#
#	@dependencies
#	functions/0200.gslog.sh
#	dependencies@
## */
function __branch_exists_remote {
	git fetch --all

	if [ -z "$1" ]; then
		__gslog "__branch_exists_remote: First parameter must be branch name."
		return 1
	fi

	local onRemote=$(git branch -r | grep "$1")
	if [ -n "$onRemote" ]; then
		return 0
	fi
	return 1
}