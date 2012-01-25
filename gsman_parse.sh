#!/bin/bash
## /*
#	@description
#	This script searches the command indexes for the specified command.
#	Once the command is found, the help file is output to the screen
#	with a colored interface.
#	description@
#
#	@notes
#	- This script is called from gsman.sh and is not intended to be a
#	  standalone script.
#	notes@
#
#	@dependencies
#	functions/0100.bad_usage.sh
#	functions/0200.gslog.sh
#	dependencies@
## */
$loadfuncs


if [ -z "$1" ]; then
	__bad_usage gsman "Invalid number of parameters."
	exit 1
fi
cmnd="$1"

# Find possible files in possible directories.
indexes=( "${gitscripts_doc_path}gsman_index.txt" )
[ -s "${gitscripts_doc_path}user/gsman_index.txt" ] && indexes[1]="${gitscripts_doc_path}user/gsman_index.txt"

# check for command in index file and grab path if it exists
for (( i = 0; i < ${#indexes[@]}; i++ )); do
	line=$(grep "^$cmnd:" "${indexes[i]}")
	[ -n "$line" ] && docPath="${line/$cmnd:/}"
done

# display help
if [ -s "$docPath" ]; then
	echo
	echo ${H2}"## /*                                           "
	echo "#   gsman: Geez man! Use the GitScripts MANual!   "
	echo "## */                                               "${X}
	echo
	echo "SCRIPT/COMMAND: "${STYLE_BRIGHT}${COL_YELLOW}${cmnd}${X}
	echo
	cat "$docPath"
	echo
	echo ${H2}"-END-"${X}
	echo

else
	__gslog "Missing documentation for ${cmnd} at ${docPath}"
	echo ${E}"  GSMan cannot find the documentation for this command.  "${X}
	exit 1
fi


exit
