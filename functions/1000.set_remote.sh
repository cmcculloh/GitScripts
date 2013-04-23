## /* @function
#	@usage __set_remote
#
#	@output on error
#
#	@vars
#	$_remote
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
#	__set_remote
#	git push $_remote branch-name-to-push
#	...
#	examples@
#
#	@file functions/1000.set_remote.sh
## */

function __set_remote {
	#This actually doesn't work properly if you have multiple remotes. If you are on a branch that targets one remote
	#and want to checkout a branch that only exists on the other remote, this will grab the remote from the branch you
	#are on, target it for the checkout, and then the checkout will fail because it is pointing at the wrong remote
	#remote=$(git config branch.$(__parse_git_branch).remote 2> /dev/null)

	if [ ! $remote ]; then
		remotes=$(git remote)

		# if no remotes are configured there's no reason to continue processing.
		if [ -z "$remotes" ]; then
			export _remote=$remotes
			return 1
		fi

		if [ $(echo $remotes | wc -w) -gt 1 ]; then
			local msg="Please choose a remote from the list above"
			__menu --prompt="$msg" $remotes && { remote=$_menu_sel_value; } || {
				return 1
			}
		else
			remote=$remotes
		fi
	fi

	export _remote=$remote
	return 0
}
