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
#	1) unignore untrackedFile.js
#	   # removes file from .gitignore
#	2) unignore trackedFile.js
#	   # Runs `git update-index --no-assume-unchanged trackedFile.js
#	3) unignore
#	   # Shows all ignored files
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
_no_menu=false
# parse arguments
if (( numArgs < 2 )); then
	until [ -z "$1" ]; do
		if [[ ${#len} == 0 ]]; then
			_file_selection=$1
		fi

		if [ "$1" == "--no-menu" ]; then
			_file_selection=
			_no_menu=true
		fi

		shift 1
	done
else
	__bad_usage unignore "Invalid number of parameters."
	exit 1
fi

ignored_files=($(git status --ignored --porcelain))
files_assumed_unchanged=($(git ls-files -v))
show_next=false
echo "${O}${STYLE_DIM}Assumed unchanged:"
echo "  (use \"unignore <file>\" to start tracking again)"
echo ${STYLE_DIM}${COL_WHITE}
for i in "${files_assumed_unchanged[@]}"
do
	# This code is garbage. I don't know how to get the current index if i == h and display
	# the next index, so that's why this hack.
	if ( $show_next ); then
		echo "	$i"
		show_next=false
	fi

	if [ $i == "h" ]; then
		show_next=true
	fi
done
echo
echo "${O}${STYLE_DIM}In .gitignore:"
echo "  (use \"unignore <file>\" to start tracking again)"
echo ${STYLE_DIM}${COL_GREY}
for i in "${ignored_files[@]}"
do
	# This code is garbage. I don't know how to get the current index if i == !! and display
	# the next index, so that's why this hack.
	if ( $show_next ); then
		is_in_gitignore=($(grep -n "$i" .gitignore))
		is_in_exclude=($(grep -n "$i" .git/info/exclude))
		if [ "$is_in_gitignore" != "" ]; then
			echo "	$i is in .gitignore"
		elif [ "$is_in_exclude" != "" ]; then
			echo "	$i is in info/exclude"
		else
			echo "	$i is implicitly excluded"
		fi
		show_next=false
	fi

	if [ $i == "!!" ]; then
		show_next=true
	fi
done

if [ -z "$_file_selection" ] && ( $_no_menu ); then
	exit
fi

echo ${X}

_file_status=($(git status $_file_selection --ignored --porcelain))
# determine which strategy we are using by looking for the ?? flag at the beginning
# of the menu selection (eg: !!--gitignored.sh)
if [[ "${_file_status:0:2}" =~ "!!" ]]; then
	_ignore_strategy="gitignore"
else
	_ignore_strategy="update-index"
fi

if [ -n "$_file_selection" ]; then
	echo
	echo
	echo "${O}Unignoring file ${B}${_file_selection}${X}."
	echo ${O}${H2HL}
	if [ $_ignore_strategy == "gitignore" ]; then
		echo "${B}${_file_selection}${O} previously gitignored. Removing from ${B}.gitignore${X}"

		is_in_gitignore=($(grep -n "$_file_selection" .gitignore))
		is_in_exclude=($(grep -n "$_file_selection" .git/info/exclude))
		if [ "$is_in_gitignore" != "" ]; then
			_line_number=($(echo $is_in_gitignore | cut -d ':' -f 1))
			echo "${A}sed -i '' -e ${_line_number}d .gitignore${X}"
			sed -i '' -e ${_line_number}d .gitignore
		elif [ "$is_in_exclude" != "" ]; then
			_line_number=($(echo $is_in_exclude | cut -d ':' -f 1))
			echo "${A}sed -i '' -e ${_line_number}d .git/info/exclude${X}"
			sed -i '' -e ${_line_number}d .git/info/exclude
		else
			echo "${W}$_file_selection is implicitly excluded and can not be unignored through this tool${X}"
		fi
		# echo "echo ${_file_selection} >> .gitignore"
		# echo ${_file_selection} >> .gitignore
	elif [ $_ignore_strategy == "update-index" ]; then
		echo "${B}${_file_selection}${O} assumed unchanged. Updating index to no longer assume unchanged."
		echo "${A}git update-index --no-assume-unchanged ${_file_selection}${X}"
		git update-index --no-assume-unchanged ${_file_selection}
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
