## /* @function
#	@usage __branch_exists_remote <branch_name>
#
#	@output on error
#
#	@description
#	Determine if the given branch exists on the remote.
#	description@
#
#	@notes
#	- Since this function does not echo anything to be captured, it is most useful if
#	used directly in conditional statements. See example below.
#	- Calling scripts are responsible for running `git fetch --all`.
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
#	@file functions/5000.branch_exists_remote.sh
## */
function __branch_exists_remote {
	if [ -z "$1" ]; then
		echo ${E}"  __branch_exists_remote: First parameter must be branch name. Nothing given.  "${X}
		return 1
	fi

	git branch -r | grep -q "$1" 2>/dev/null
}
