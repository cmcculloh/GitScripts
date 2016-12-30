#!/bin/bash
## /*
#	@usage add [file-name]
#
#	@description
#	This script makes staging files for commit much easier. It fully supports
#	tab completion in a way that the built in git add does not. Also, if you
#	prefer to use a menu over tab completion, it supports that too.
#	description@
#
#
#	@examples
#	1) add
#	   # Will show a list of files available for staging.
#	2) add fi[tab]
#	   # tab completes the rest of the file name
#	3) add file-path/file.sh
#	   # deduces if you are doing an add or rm and then does the operation.
#	examples@
#
#	@dependencies
#	functions/0300.menu.sh
#	dependencies@
#
#	@file add.sh
## */
$loadfuncs


echo ${X}

numArgs=$#

_file_selection=
gitcommand="add"
_whitespace_only=false
# parse arguments
if (( numArgs < 4 )); then
	until [ -z "$1" ]; do
		{ [ "$1" == "-a" ] || [ "$1" == "-A" ] || [ "$1" == "-w" ]; } && _file_selection=$1
		! echo "$1" | egrep -q "^-" && msg="$1"

		if [ "$1" == "-a" ]; then
			_file_selection="."
		fi

		if [ "$1" == "-w" ]; then
			_file_selection="-A"
			_whitespace_only=true
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

#no file specified, show menu
if [ -z "$_file_selection" ]; then
	msg="Please choose a file to stage."
	__menu --prompt="$msg" ${list[@]}

	#determine if we are adding or deleting
	if [[ "$_menu_sel_value" == "D-"* ]] || [[ "$_menu_sel_value" == "-D"* ]]; then
		gitcommand="rm"
	fi

	# clean the flags out of the file name
	shopt -s extglob #http://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
	_file_selection=${_menu_sel_value/@(M--|-M-|D--|-D-|\?\?-)/}
else
	#they passed in the file pattern, now determine if we need to do an add or a delete
	for e in "${list[@]}"; do
		if [[ "$e" =~ "$_file_selection" ]]; then
			if [[ "$e" == "D-"* ]] || [[ "$e" == "-D"* ]]; then
				gitcommand="rm"
			fi
		fi
	done

fi

echo
echo
echo "Staging file ${COL_GREEN}${_file_selection}${COL_NORM} for commit."
echo ${O}${H2HL}
echo "$ git ${gitcommand} ${_file_selection}"
git ${gitcommand} ${_file_selection}

if ( $_whitespace_only ) ; then
	echo "git diff --cached -w | git apply --cached -R"
	git diff --cached -w | git apply --cached -R
fi

echo ${O}${H2HL}${X}
echo
echo

# Show status for informational purposes
echo "$ git status"
git status
echo ${O}${H2HL}${X}


exit