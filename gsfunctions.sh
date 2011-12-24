function __parse_git_branch {
	if [ "$windows" == "true" ]; then
		git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
	else
		git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/\* (.*)/\1/'
	fi
}


## /*
#	@usage __bad_usage [command_name [message]]
#
#	@description
#	Makes error messages a little easier to read. They are prefixed with the command name,
#	include coloring, and direct the user to use the GS Manual. However, if the user wishes
#	to use this function with a command that has no gsman entry, option -o can be used
#	and the reference to the gsman entry will be omitted.
#	description@
#
#	@notes
#	- A message cannot be given without a command name.
#	notes@
#
#	@examples
#	1) __bad_usage checkout "That branch name does not exist."
#		returns: checkout: That branch name does not exist. Use "gsman checkout" for usage instructions.
#	2) __bad_usage -o fixbranch
#		returns: fixbranch: Invalid usage.
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


## /*
#	@usage parse_git_dirty
#
#	@description
#	Outputs flags of the current branch state.
#
#	origin of work http://henrik.nyh.se/2008/12/git-dirty-prompt
#	These are the character codes I used for the git dirty state in the project.
#	??? ? files have been modified
#	??? ? there are untracted files in the project
#	?*? ? a new file has been add to the project but not committed
#	?+? ? the local project is ahead of the remote
#	?>? ? file has been moved or renamed
#	description@
#
#	@notes
#
#	notes@
#
#	@examples
#
#	examples@
## */
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
function parse_git_dirty {
  status=`git status 2> /dev/null`
  staged=` echo -n "${status}" 2> /dev/null | grep -q "Changes to be committed" 2> /dev/null; echo "$?"`
  dirty=`    echo -n "${status}" 2> /dev/null | grep -q "Changed but not updated" 2> /dev/null; echo "$?"`
  untracked=`echo -n "${status}" 2> /dev/null | grep -q "Untracked files" 2> /dev/null; echo "$?"`
  ahead=`    echo -n "${status}" 2> /dev/null | grep -q "Your branch is ahead of" 2> /dev/null; echo "$?"`
  newfile=`  echo -n "${status}" 2> /dev/null | grep -q "new file:" 2> /dev/null; echo "$?"`
  renamed=`  echo -n "${status}" 2> /dev/null | grep -q "renamed:" 2> /dev/null; echo "$?"`
  modified=`  echo -n "${status}" 2> /dev/null | grep -q "modified:" 2> /dev/null; echo "$?"`
  bits=''

  if [ "${dirty}" == "0" ]; then
    bits="${bits} ${X}${STYLE_DIRTY} + (dirty) ${X}"
  fi
  if [ "${modified}" == "0" -a "${staged}" == "0" -a "${dirty}" == "1" ]; then
    bits="${bits} ${X}${STYLE_COMMITTED} ++ (staged) ${X}"
  fi

  if [ "${modified}" == "0" -a "${staged}" == "0" -a "${dirty}" == "0" ]; then
    bits="${bits} ${X}${STYLE_MODIFIED} >> (modified) ${X}"
  fi


  if [ "${modified}" == "0" -a "${staged}" == "1" ]; then
    bits="${bits} ${X}${STYLE_MODIFIED} >> (modified) ${X}"
  fi
  if [ "${untracked}" == "0" ]; then
    bits="${bits} ${X}${STYLE_UNTRACKED} ? (untracked) ${X}"
  fi
  if [ "${newfile}" == "0" ]; then
    bits="${bits} ${X}${STYLE_NEWFILE} * (newfile) ${X}"
  fi
  if [ "${ahead}" == "0" ]; then
    bits="${bits} ${X}${STYLE_AHEAD} + (ahead) ${X}"
  fi
  if [ "${renamed}" == "0" ]; then
    bits="${bits} > (renamed) "
  fi
  echo "${bits}"
}


function __parse_git_branch_state {
#  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/(\1$(parse_git_dirty))/"
  echo "$(parse_git_dirty)"
}
