## /* @function
#	@usage __parse_git_status <state_flag>
#
#	@output false
#
#	@description
#	Determine various states of files in your current working tree. Currently supported
#	state_flags are (see function definition for how states are determined):
#
#	ahead, clean, dirty, newfile, renamed, staged, untracked
#	description@
#
#	@notes
#	- If no parameter or an invalid parameter is given, the failure is logged and the
#	the function returns status 1.
#	- The output of the grep command is intentionally suppressed as this function
#	is intended to be used as a boolean in conditional expressions.
#	notes@
#
#	@examples
#	# ... user makes some changes and attempts to switch branches ...
#
#	if __parse_git_status dirty; then
#		echo "Are you sure you want to change branches? You have uncommitted changes."
#		# ... parse answer and act accordingly ...
#	fi
#
#	# ...
#	examples@
## */
function __parse_git_status {
	if [ -z "$1" ]; then
		__gslog "__parse_git_status: Invalid usage. A parameter matching status type is required."
		return 1
	fi

	# check for given status
	case $1 in
		"ahead")
			searchstr="Your branch is ahead of";;

		"behind")
			searchstr="Your branch is behind";;

		"clean")
			searchstr="working directory clean";;

		"modified")
			# first pattern for older versions of Git
			searchstr="Changed but not updated\\|Changes not staged for commit";;

		"newfile")
			# only returns true if file has been staged
			searchstr="new file:";;

		"renamed")
			searchstr="renamed:";;

		"deleted")
			searchstr="deleted:";;

		"staged")
			searchstr="Changes to be committed";;

		"untracked")
			searchstr="Untracked files";;

		*)
			__gslog "__parse_git_status: Invalid parameter given  <$1>"
			return 1
			;;
	esac

	# use the return value of the grep as the return value of the function
	git status 2> /dev/null | grep -q "$searchstr" 2> /dev/null
}