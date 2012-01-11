## /* @function
#	@usage __parse_git_branch_state
#
#	@output true
#
#	@description
#	Outputs flags of the current branch state. Currently flagged states are:
#
#	ahead, dirty, modified, newfile, renamed, staged, untracked
#
#	origin of work http://henrik.nyh.se/2008/12/git-dirty-prompt
#	These are the character codes we use for the different states. States with the same codes
#	have been set to differ in color by default.
#
#	 + (ahead)     Local branch is ahead (contains additional commits) of remote branch
#	 - (behind)     Local branch is behind (missing commits) that are on the remote branch
#	+- (dirty)     Tracked files have been modified but not staged.
#	>> (modified)  Tracked files have been modified
#	 * (newfile)   A new file has been staged (if unstaged the file is considered untracked).
#	 > (renamed)   A tracked file has been identified as being renamed. Applies to staged/unstaged.
#	!* (deleted)   A tracked file has been identified as being deleted. Applies to staged/unstaged.
#	++ (staged)    A file has been staged for the next commit.
#	 ? (untracked) One or more untracked files have been identified.
#	description@
#
#	@examples
#	- Assume a tracked file has been staged, another has been modified, and a new file has been
#	created in the working tree. A user might write a script like so:
#		source ${gitscripts_path}gsfunctions.sh
#		export branch_state=$(__parse_git_branch_state)
#		echo "The current branch has the following state(s): ${branch_state}"
#	>> output (with colors): The current branch has the following state(s):  + (dirty)  ++ (staged)  ? (untracked)
#	examples@
## */
function __parse_git_branch_state {
	__parse_git_status ahead 		&& local ahead=true
	__parse_git_status behind 		&& local behind=true
	__parse_git_status deleted 		&& local deleted=true
	__parse_git_status modified 	&& local modified=true
	__parse_git_status newfile 		&& local newfile=true
	__parse_git_status renamed 		&& local renamed=true
	__parse_git_status staged 		&& local staged=true
	__parse_git_status untracked	&& local untracked=true
	bits=


	if [ $staged ]; then
		bits="${bits} ${X}${STYLE_COMMITTED} ++ (staged) ${X}"

		if [ $newfile ]; then
			bits="${bits} ${X}${STYLE_NEWFILE} * (new files) ${X}"
		fi
		if [ $renamed ]; then
			bits="${bits} ${X}${STYLE_RENAMEDFILE} > (renamed) ${X}"
		fi
		if [ $modified ]; then
			bits="${bits} ${X}${STYLE_DIRTY} +- (dirty) ${X}"
		fi
	fi

	if [ $deleted ]; then
		bits="${bits} ${X}${STYLE_DELETEDFILE} !* (deleted files) ${X}"
	fi

	if [ $modified ] && [ ! $staged ]; then
		bits="${bits} ${X}${STYLE_MODIFIED} >> (modified) ${X}"
	fi

	if [ $untracked ]; then
		bits="${bits} ${X}${STYLE_UNTRACKED} ? (untracked) ${X}"
	fi

	if [ $ahead ]; then
		bits="${bits} ${X}${STYLE_AHEAD} + (ahead) ${X}"
	fi

	if [ $behind ]; then
		bits="${bits} ${X}${STYLE_AHEAD} - (behind) ${X}"
	fi

	echo "$bits"
}