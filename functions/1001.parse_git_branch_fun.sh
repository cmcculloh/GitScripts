## /* @function
#	@usage __parse_git_branch_fun
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
#	@examples
#	cb=$(__parse_git_branch_fun)
#	examples@
#
#	@dependencies
#	functions/0500.is_repo.sh
#	dependencies@
#
#	@file functions/1001.parse_git_branch_fun.sh
## */
function __parse_git_branch_fun {

	if [ __is_repo ]; then
		theBranchName=`expr "$(git symbolic-ref HEAD)" : 'refs/heads/\(.*\)'`;
		if [[ $theBranchName == "master" ]]; then
			theBranchName="🐙  ${theBranchName}";
		fi
		echo "${theBranchName}";
	fi
}
