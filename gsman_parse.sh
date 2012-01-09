#!/bin/bash

if [ -z "$1" ]; then
	echo "Error: gsman_parse.sh expects a file name in the gitscripts directory as a parameter."
	exit 1
fi


# Find possible files in possible directories.
both_paths="${gsman_paths_default} ${gsman_paths_user}"
file_list=""
for gsman_path in $both_paths; do
	for listing in `ls -p "$gsman_path" | grep -v '/' | egrep "$1\\.[_[:alnum:]]+$"`; do
		#conditional eliminates excessive spaces
		[ -z "$file_list" ] && { file_list="${gsman_path}$listing"; } || {
			file_list="${file_list} ${gsman_path}$listing"
		}
	done
done
file_array=( $file_list )

# If there is more than one file in the array, user should get a choice of which to view.
if [ ${#file_array[*]} -gt 1 ]; then
	echo
	echo ${O}"GSMan found multiple possible scripts for ${COL_MAG}$1${COL_NORM}${O}."
	echo ${H2HL}
	num=0
	for li in $file_list; do
		echo "$num:  $li"
		(( num++ ))
	done
	echo ${H2HL}
	echo ${Q}"Please make a selection from the list (or press enter to abort): "${X}
	read choice
	if [ -n "$(echo $choice | egrep '^[[:digit:]]+$')" ]; then
		file=${file_array[choice]}
	else
		echo ${O}"No choice selected. Exiting gsman..."${X}
		echo
		exit
	fi
else
	file=$file_list
fi


# awk does all the heavy lifting (parsing)
# todo: check for $tmp file
awkscript="${gitscripts_awk_path}gsman_parse.awk"
result=$(awk -f $awkscript $file 2>&1 | tee $tmp)

if [ -z "$result" ]; then
	echo
	echo ${E}" No documentation found for ${1}!"${X}
	echo
else
	echo
	echo ${H2}"## /*                                           "
	echo "#   gsman: Geez man! Use the GitScripts MANual!   "
	echo "## */                                               "${X}
	echo
	echo "SCRIPT/COMMAND: "${STYLE_BRIGHT}${COL_YELLOW}$1
	echo ${X}
	cat "$tmp"
	echo
	echo ${H2}"-END-"${X}
	echo
fi