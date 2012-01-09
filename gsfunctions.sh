## /*
#	@usage __bad_usage [options] [command_name [message]]
#
#	@output true
#
#	@description
#	Makes error messages a little easier to read. They are prefixed with the command name,
#	include coloring, and direct the user to use the GS Manual. However, if the user wishes
#	to use this function with a command that has no gsman entry, option -o can be used
#	and the reference to the gsman entry will be omitted.
#	description@
#
#	@options
#	-o	Omit the reference to gsman for usage instructions. If this option is given, only the
#		command_name is used. Any further parameters are ignored.
#	options@
#
#	@notes
#	- A message cannot be given without a command name.
#	notes@
#
#	@examples
#	1) __bad_usage checkout "That branch name does not exist."
#		>> checkout: That branch name does not exist. Use "gsman checkout" for usage instructions.
#	2) __bad_usage -o merge
#		>> merge: Invalid usage.
#	3) __bad_usage
#		>> Error: Invalid usage. Use "gsman <command>" for usage instructions.
#	examples@
## */
function __bad_usage {
	# custom __bad_usage function for gitscript commands which implement gsman comments
	#	$1 - command name (optional)
	#	$2 - custom message (optional)
	hcolor=${COL_MAG}

	case $# in
		1)
			# 1st argument MUST be script/command name which has NO spaces and is not an option (-o)
			local space=$(echo $1 | grep '[- ]')
			if [ -n "$space" ]; then
				echo ${hcolor}"__bad_usage: Invalid usage."${X}" Use \""${hcolor}"gsman gsfunctions"${X}"\" for usage instructions."
			else
				echo ${hcolor}"${1}: "${X}"Invalid usage. Use \""${hcolor}"gsman ${1}"${X}"\" for usage instructions."
			fi
			;;

		2)
			if [ "$1" == "-o" ]; then
				# 2nd argument MUST be script/command name which has NO spaces
				local space=$(echo $2 | grep '[ ]')
				if [ -n "$space" ]; then
					echo ${hcolor}"__bad_usage: Invalid usage."${X}" Use \""${hcolor}"gsman gsfunctions"${X}"\" for usage instructions."
				else
					echo ${hcolor}"${2}: "${X}"Invalid usage."
				fi
			else
				echo ${hcolor}"${1}: "${X}"${2} Use \""${hcolor}"gsman ${1}"${X}"\" for usage instructions."
			fi
			;;

		3)
			if [ "$1" == "-o" ]; then
				echo ${hcolor}"${2}: "${X}"${3}"
			else
				echo ${hcolor}"__bad_usage: Invalid usage."${X}" Use \""${hcolor}"gsman gsfunctions"${X}"\" for usage instructions."
			fi
			;;

		*)
			echo "Error: Invalid usage. Use \""${hcolor}"gsman <command>"${X}"\" for usage instructions."
			;;
	esac
}


## /* @function
#	@usage __gslog <data>
#
#	@output file
#
#	@description
#	A custom logger for GitScripts. Usually failure messages that aren't useful to the user, but may be to
#	a developer will be put here as opposed to echoed to standard output.
#	description@
#
#	@notes
#	- Appends to log file only if a parameter is given and log file exists.
#	notes@
#
#	@examples
#	1) __gslog "starting my script..."
#	2) if [ $myage -lt 40 ]; then __gslog "You've still got time..."; fi
#	examples@
#
#	@dependencies
#	[vars] $gslog (path to log file)
#	dependencies@
## */
function __gslog {
	if [ -n "$1" -a -f "$gitscripts_log" ]; then
		echo >> $gitscripts_log
		echo "###################################  "$(date)"  ###################################" >> $gitscripts_log
		echo >> $gitscripts_log
		echo $1 >> $gitscripts_log
		echo >> $gitscripts_log
		echo >> $gitscripts_log
	fi
}


## /* @function
#	@usage __branch_exists <branch_name>
#
#	@output false
#
#	@description
#	Determine if the given branch exists either locally or remotely. If it exists locally,
#	skip checking for the remote branch.
#	description@
#
#	@notes
#	- Since this function does not echo anything to be captured, it is most useful if
#	used directly in conditional statements. See example below.
#	notes@
#
#	@examples
#	# ...
#
#	if __branch_exists master; then
#		echo "Branch 'master' exists!"
#	fi
#
#	#...
#	examples@
## */
function __branch_exists {
	if [ -z "$1" ]; then
		__gslog "__branch_exists: First parameter must be branch name."
		return 1
	fi

	local locally=$(git branch | grep "$1")
	if [ -n "$locally" ]; then
		return 0
	else
		local remotely=$(git branch -r | grep "$1")
		if [ -n "$remotely" ]; then
			return 0
		fi
	fi
	return 1
}

## /* @function
#	@usage __branch_exists_locally <branch_name>
#
#	@output false
#
#	@description
#	Determine if the given branch exists locally.
#	description@
#
#	@notes
#	- Since this function does not echo anything to be captured, it is most useful if
#	used directly in conditional statements. See example below.
#	notes@
#
#	@examples
#	# ...
#
#	if __branch_exists_locally master; then
#		echo "local branch 'master' exists!"
#	fi
#
#	#...
#	examples@
## */
function __branch_exists_locally {
	if [ -z "$1" ]; then
		__gslog "__branch_exists_locally: First parameter must be branch name."
		return 1
	fi

	local locally=$(git branch | grep "$1")
	if [ -n "$locally" ]; then
		return 0
	fi
	return 1
}
## /* @function
#	@usage __branch_exists_remote <branch_name>
#
#	@output false
#
#	@description
#	Determine if the given branch exists on the remote.
#	description@
#
#	@notes
#	- Since this function does not echo anything to be captured, it is most useful if
#	used directly in conditional statements. See example below.
#	notes@
#
#	@examples
#	# ...
#
#	if __branch_exists_remote master; then
#		echo "remote branch 'master' exists!"
#	fi
#
#	#...
#	examples@
## */
function __branch_exists_remote {
	if [ -z "$1" ]; then
		__gslog "__branch_exists_remote: First parameter must be branch name."
		return 1
	fi

	local onRemote=$(git branch -r | grep "$1")
	if [ -n "$onRemote" ]; then
		return 0
	fi
	return 1
}

## /* @function
#	@usage __branch_merge_set <branch_name>
#
#	@output false
#
#	@description
#	Determine if the given branch exists either locally or remotely. If it exists locally,
#	skip checking for the remote branch.
#	description@
#
#	@notes
#	- Since this function does not echo anything to be captured, it is most useful if
#	used directly in conditional statements. See example below.
#	notes@
#
#	@examples
#	# ...
#
#	if __branch_exists master; then
#		echo "Branch 'master' exists!"
#	fi
#
#	#...
#	examples@
## */
function __branch_merge_set {
	if [ -z "$1" ]; then
		__gslog "__branch_merge_set: First parameter must be branch name."
		return 1
	fi

	local configExists=$(git config --get branch.$1.merge)
	if [ -n "$configExists" ]; then
		return 0
	else
		return 1
	fi
	return 1
}


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


## /* @function
#	@usage __parse_git_branch
#
#	@output true
#
#	@description
#	Determine which branch the current repository (working tree) has checked out.
#	description@
#
#	@notes
#	- When using this function, capture the output (the branch name, if any).
#	notes@
## */
function __parse_git_branch {
	git status >/dev/null 2>&1 && expr "$(git symbolic-ref HEAD)" : 'refs/heads/\(.*\)'
}


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
