#!/bin/bash
## /*
#	@usage ignore [file-string]
#
#	@description
#	Allows for adding a file to ignore list if untracked, otherwise adds to
#	assume unchanged list
#	description@
#
#	@examples
#	1) ignore untrackedFile.js
#	   # adds untrackedFile.js to .gitignore
#	2) ignore trackedFile.js
#	   # Runs `git update-index --assume-unchanged trackedFile.js
#	examples@
#
#	@dependencies
#	functions/0300.menu.sh
#	dependencies@
#
#	@file ignore.sh
## */
$loadfuncs


echo ${X}

numArgs=$#

_file_selection=
_ignore_strategy=
_whitespace_only=false
# parse arguments
# Can only pass -a, -A, or single file name, plus the -w flag. Two possible max.
if (( numArgs < 2 )); then
	until [ -z "$1" ]; do
		if [[ ${#len} == 0 ]]; then
			_file_selection=$1
		fi

		shift 1
	done
else
	__bad_usage commit "Invalid number of parameters."
	exit 1
fi

list=($(git status --porcelain | tr " " -))
#clean the list up so already added files aren't options
list=( ${list[@]/M--*/} )
list=( ${list[@]/D--*/} )
list=( ${list[@]/A--*/} )

# make sure they did not pass a partial filename, if so, strip it to bring up menu
_passed_partial=true
for e in "${list[@]}"; do
	# $e at this point has the funny -M- prepended to it, ignore that stuff
	if [[ "${e:3}" == "$_file_selection" ]]; then
		# found the file, they did not pass a partial
		_passed_partial=false
	fi
done

if ( $_passed_partial ); then
	# trash the selection. Maybe someday we can par the list down by partial matches instead...
	_file_selection=''
fi

#no file specified, show menu
if [ -z "$_file_selection" ] && ( $_passed_partial ); then
	msg="Please choose a file to stage."
	__menu --prompt="$msg" ${list[@]}

	# clean the flags out of the file name
	shopt -s extglob #http://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
	_file_selection=${_menu_sel_value/@(M--|-M-|D--|-D-|\?\?-)/}

	# determine if we are adding or deleting by looking for the D flag at the beginning
	# of the menu selection (eg: -D--add.sh)
	if [[ "${_menu_sel_value:0:2}" =~ "??" ]]; then
		_ignore_strategy="gitignore"
	else
		_ignore_strategy="update-index"
	fi
fi

echo

if [ -n "$_file_selection" ]; then
	echo
	echo
	echo "Ignoring file ${COL_GREEN}${_file_selection}${COL_NORM}."
	echo ${O}${H2HL}
	if [ $_ignore_strategy == "gitignore" ]; then
		echo "File previously untracked. Adding to .gitignore"
		echo "echo ${_file_selection} >> .gitignore"
		echo ${_file_selection} >> .gitignore
	elif [ $_ignore_strategy == "update-index" ]; then
		echo "File previously tracked. Updating index to assume unchanged."
		echo "git update-index --assume-unchanged ${_file_selection}"
		git update-index --assume-unchanged ${_file_selection}
	fi

	echo ${O}${H2HL}${X}
	echo
	echo

	# Show status for informational purposes
	echo "$ git status"
	git status
	echo ${O}${H2HL}${X}

else
	echo "  aborting"
fi

exit
