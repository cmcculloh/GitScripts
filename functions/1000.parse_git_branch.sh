## /* @function
#	@usage __parse_git_branch
#
#	@output true
#
#	@description
#	Determine which branch the current repository (working tree) has checked out.
#	The function call will fail silently if working directory is not a git
#	repository.
#	description@
#
#	@notes
#	- When using this function, capture the output (the branch name, if any).
#	notes@
#
#	@file functions/1000.parse_git_status.sh
## */
function __parse_git_branch {
	git status --porcelain >/dev/null 2>&1 && expr "$(git symbolic-ref HEAD)" : 'refs/heads/\(.*\)'
}
