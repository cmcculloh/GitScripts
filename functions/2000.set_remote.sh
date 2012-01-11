## /* @function
#	@usage __get_remote
#
#	@output true
#
#	@description
#	This function searches all the remotes for a git project and will present a menu
#	to choose one if multiple remotes have been configured. If only one remote has been configured
#	it will bypass the menu process and simply return that remote string. If no remotes are
#	configured, there will be no output.
#	description@
#
#	@notes
#	- This function is intended to be used for it's output, not in conditionals.
#	notes@
#
#	@examples
#	...
#	remote=$(__get_remote)
#	git push $remote branch-name-to-push
#	...
#	examples@
## */
function __get_remote {
	local cb=$(__parse_git_branch)
	local remote=$(git config branch.$cb.remote)

	if [ ! $remote ]; then
	remotes_string=$(git remote);

	# if no remotes are configured there's no reason to continue processing.
	if [ -z "$remotes_string" ]; then
		exit 1
	fi

	c=0;
	for remote in $remotes_string; do
		remotes[$c]=$remote;
		(( c++ ));
	done

	# if more than one remote exists, give the user a choice.
	if [ ${#remotes[@]} -gt 1 ]; then
		echo ${O}${H2HL}
		for (( i = 0 ; i < ${#remotes[@]} ; i++ )); do
			remote=$(echo ${remotes[$i]} | sed 's/[a-zA-Z0-9\-]+(\/\{1\}[a-zA-Z0-9\-]+)//p')

			if [ $i -le "9" ]; then
				index="  "$i
			elif [ $i -le "99" ]; then
				index=" "$i
			else
				index=$i
			fi
			echo "$index: $remote"
		done
		echo ${H2HL}${X}
		echo ${I}"Choose a remote (or just hit enter to abort):"
		read remote
		echo ${X}

		remote=$(echo ${remotes[$remote]} | sed 's/\// /')
	else
		remote=${remotes[0]}
	fi
	fi
	echo "$remote"
}