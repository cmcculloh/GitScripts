## /* @function
#	@usage __is_repo
#
#	@output false
#
#	@description
#	A quick check to see if the current working directory is in the path
#	of a git repository.
#	description@
#
#	@notes
#	- Intended to be used in conditional statements.
#	notes@
#
#	@file functions/0500.is_repo.sh
## */
function __is_repo {
	git branch >/dev/null 2>&1
}
