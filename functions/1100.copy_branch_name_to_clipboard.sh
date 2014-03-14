## /* @function
#	@usage __copy_branch_name_to_clipboard
#
#	@output true
#
#	@description
#	Copies the current Git branch name to the clipboard.
#	description@
#
#	@notes
#	- When using this function, capture the output (the branch name, if any).
#	notes@
#
#	@examples
#	cb=$(__copy_branch_name_to_clipboard)
#	examples@
#
#	@dependencies
#	functions/0500.is_repo.sh
#	functions/1000.parse_git_branch.sh
#	dependencies@
#
#	@file functions/1100.copy_branch_name_to_clipboard.sh
## */
function __copy_branch_name_to_clipboard {

	! __is_repo && echo "  ${W}Not currently in a Git repository.${X}"

	if [[ __is_repo ]]; then

		currentbranch=$(__parse_git_branch);
		result=$(echo "${currentbranch}")

		echo -n $result | pbcopy

		echo
		echo "  ${B}\`${currentbranch}\`${X} has been copied to your clipboard."
	fi


}
