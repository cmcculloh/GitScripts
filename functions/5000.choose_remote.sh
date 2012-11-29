## /* @function
#	@usage __choose_remote
#
#	@description
#	Allow user to choose a remote to target
#	description@
#
#	@examples
#	__choose_remote
#	examples@
#
#	@file functions/5000.choose_remote.sh
## */
function __choose_remote {
	remotes=$(git remote)

	# if no remotes are configured there's no reason to continue processing.
	if [ -z "$remotes" ]; then
		export _remote=$remotes
		return 1
	fi

	if [ $(echo $remotes | wc -w) -gt 1 ]; then
		local msg="Please choose a remote from the list above"
		__menu --prompt="$msg" $remotes && {
			remote=$_menu_sel_value;
			if [ -z "$remote" ]; then
				#if they aborted, propagate the abortion
				return 1
			fi
		} || {
			return 1
		}
	else
		remote=$remotes
	fi

	export _remote=$remote
	return 0
}