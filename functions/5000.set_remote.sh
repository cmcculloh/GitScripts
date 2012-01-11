## /*
#	@usage __set_remote
#
#	@output on error
#
#	@vars
#	_remote
#	vars@
#
#	@description
#	This script sets a variable that represents the name of a configured git remote repository.
#	It first checks to see if the current branch is tracking a remote repository. If so, it
#	"chooses" that remote. If not, it searches all the remotes for a git project and will present a menu
#	to choose one if multiple remotes have been configured. If only one remote has been configured
#	it will bypass the menu process and simply return that remote string. If no remotes are
#	configured, the $_remote variable will not be set.
#	description@
#
#	@notes
#	- This file must be SOURCED to get access to the variable ($_remote) which is set for use.
#	- This file is intended to be used for it's output, not in conditionals.
#	notes@
#
#	@examples
#	...
#	$set_remote
#	git push $remote branch-name-to-push
#	...
#	examples@
## */

function __set_remote {
	remote=$(git config branch.$(__parse_git_branch).remote 2> /dev/null)

	if [ ! $remote ]; then
		remotes=$(git remote)

		# if no remotes are configured there's no reason to continue processing.
		if [ -z "$remotes" ]; then
			return 1
		fi

		if [ $(echo $remotes | wc -w) -gt 1 ]; then
			__menu "$remotes" && { remote=$_menu_selection; } || {
				echo
				echo ${E}"  Unable to determine a remote!  "${X}
				return 1
			}
		else
			remote=$remote
		fi
	fi

	export _remote=$remote
	return 0
}
