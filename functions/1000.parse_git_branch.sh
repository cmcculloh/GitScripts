## /* @function
#	@usage __parse_git_branch
#
#	@output true
#
#	@description
#	Determine which branch the current repository (working tree) has checked out.
#	description@
#
#	@notes
#	- When using this function, capture the output (the branch name, if any).
#	notes@
## */
function __parse_git_branch {
	git status --porcelain >/dev/null 2>&1 && expr "$(git symbolic-ref HEAD)" : 'refs/heads/\(.*\)'
}