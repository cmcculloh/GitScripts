## /* @function
#	@usage __parse_git_branch_state
#
#	@output true
#
#	@description
#	Outputs flags of the current branch state. Currently flagged states are:
#
#	ahead, behind, deleted files, modified, new files, no remote, renamed, staged, untracked
#
#	origin of work http://henrik.nyh.se/2008/12/git-dirty-prompt
#	These are the character codes we use for the different states. States with the same codes
#	have been set to differ in color by default.
#
#	 + (ahead)           Local branch is ahead (contains additional commits) of remote branch
#	 - (behind)          Local branch is behind (missing commits) that are on the remote branch
#	!* (deleted files)   A tracked file has been identified as being deleted. Applies to staged/unstaged.
#	>> (modified)        Tracked files have been modified
#	 * (new files)       A new file has been staged (if unstaged the file is considered untracked).
#	X> (no remote)       (optional) The branch is not tracking a remote branch
#	 > (renamed files)   A tracked file has been identified as being renamed. Applies to staged/unstaged.
#	++ (staged)          A file has been staged for the next commit.
#	?? (untracked)       One or more untracked files have been identified.
#	description@
#
#	@examples
#	- Assume a tracked file has been staged, another has been modified, and a new file has been
#	created in the working tree. Consider the following snippet:
#
#		source ${gitscripts_lib_path}source_files.sh
#		export branch_state=$(__parse_git_branch_state)
#		echo "The current branch has the following state(s):"
#		echo "${branch_state}"
#
#		# output:
#		# The current branch has the following state(s):
#		#  >> (modified)  ++ (staged)  ?? (untracked)
#	examples@
#
#	@dependencies
#	functions/0500.is_repo.sh
#	functions/5000.parse_git_status.sh
#	dependencies@
#
#	@file functions/5000.parse_git_branch_state.sh
## */
function __parse_git_branch_state {
	! __is_repo && echo ${COL_MAGENTA}"not a repository"${X} && exit

	# this function call exports all the state variables prefixed with _pgs_ below
	__parse_git_status all

	local bits=

	if [ $_pgs_staged ]; then
		bits="${bits} ${STYLE_STAGED} ++ (staged) ${X}"

		# these two don't HAVE to be here, but we know they won't be triggered unless
		# staged state is triggered. saves a bit of processing power.
		if [ $_pgs_newfile ]; then
			bits="${bits} ${STYLE_NEWFILE} * (new files) ${X}"
		fi
		if [ $_pgs_renamed ]; then
			bits="${bits} ${STYLE_RENAMEDFILE} > (renamed files) ${X}"
		fi
	fi

	if [ $_pgs_deleted ]; then
		bits="${bits} ${X}${STYLE_DELETEDFILE} !* (deleted files) ${X}"
	fi

	if [ $_pgs_modified ]; then
		bits="${bits} ${X}${STYLE_MODIFIED} >> (modified) ${X}"
	fi

	if [ $_pgs_untracked ]; then
		bits="${bits} ${X}${STYLE_UNTRACKED} ?? (untracked) ${X}"
	fi

	if [ $_pgs_ahead ]; then
		bits="${bits} ${X}${STYLE_AHEAD} + (ahead) ${X}"
	fi

	if [ $_pgs_behind ]; then
		bits="${bits} ${X}${STYLE_BEHIND} - (behind) ${X}"
	fi

	if [ "$showremotestate" = "y" ] && [ ! $_pgs_onremote ]; then
		bits="${bits} ${X}${STYLE_NO_REMOTE} X> (no remote) ${X}"
	fi

	echo "$bits"
}
