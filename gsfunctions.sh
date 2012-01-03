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
	git branch --no-color 2> /dev/null | awk '/^* / { gsub(/^* /,""); print }'
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

		"clean")
			searchstr="working directory clean";;

		"dirty")
			# older Git versions use the first terminology
			searchstr="Changed but not updated\\|Changes not staged for commit";;

		"modified")
			# older Git versions use the first terminology
			searchstr="no changes added to commit";;

		"newfile")
			searchstr="new file:";;

		"renamed")
			searchstr="renamed:";;

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
#	 + (dirty)     Tracked files have been modified but not staged.
#	>> (modified)  Tracked files have been modified
#	 * (newfile)   A new file has been staged (if unstaged the file is considered untracked).
#	 > (renamed)   A tracked file has been identified as being renamed. Applies to staged/unstaged.
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
	__parse_git_status ahead && ahead=true
	__parse_git_status dirty && dirty=true
	__parse_git_status modified && modified=true
	__parse_git_status newfile && newfile=true
	__parse_git_status renamed && renamed=true
	__parse_git_status staged && staged=true
	__parse_git_status untracked && untracked=true
	bits=''

	echo " Staged: ${staged} | Dirty: ${dirty} | Modified: ${modified} "

	if [ -n "${dirty}" ]; then
		bits="${bits} ${X}${STYLE_DIRTY} + (dirty) ${X}"
	fi

	if [ -n "${staged}" ]; then
		bits="${bits} ${X}${STYLE_COMMITTED} + (staged) ${X}"
	fi

	if [ -n "${modified}" ]; then
		bits="${bits} ${X}${STYLE_MODIFIED} >> (modified) ${X}"
	fi

	# if [ -n "${modified}" -a -n "${staged}" -a -z "${dirty}" ]; then
	# 	echo "staged!"
	# 	bits="${bits} ${X}${STYLE_COMMITTED} ++ (staged) ${X}"
	# fi
	# if [ -n "${modified}" -a -n "${staged}" -a -n "${dirty}" ]; then
	# 	bits="${bits} ${X}${STYLE_MODIFIED} >> (modified) ${X}"
	# fi
	# if [ -n "${modified}" -a -z "${staged}" ]; then
	# 	bits="${bits} ${X}${STYLE_MODIFIED} >> (modified) ${X}"
	# fi
	if [ -n "${untracked}" ]; then
		bits="${bits} ${X}${STYLE_UNTRACKED} ? (untracked) ${X}"
	fi
	if [ -n "${newfile}" ]; then
		bits="${bits} ${X}${STYLE_NEWFILE} * (newfile) ${X}"
	fi
	if [ -n "${ahead}" ]; then
		bits="${bits} ${X}${STYLE_AHEAD} + (ahead) ${X}"
	fi
	if [ -n "${renamed}" ]; then
		bits="${bits} > (renamed) "
	fi

	echo "${bits}"
}
