#!/bin/bash

if [ -z "$1" ]; then
	echo "Error: gsman_parse.sh expects a file name in the gitscripts directory as a parameter."
	exit 1
fi

arg="${gitscripts_path}$1"
if [ ! -f "$arg" ]; then
	if [ ! -f "${arg}.sh" ]; then
		if [ ! -f "${arg}.overrides" ]; then
			echo "Error: Cannot find file ${arg}, ${arg}.sh, or ${arg}.overrides. gsman_parse.sh cannot parse a non-existent file."
			exit 2
		fi
	else
		file="${arg}.sh"
	fi
else
	file="$arg"
fi

awkscript="${awkdir}gsman_parse.awk"

# awk does all the heavy lifting (parsing)
result=$(awk -f $awkscript $file 2>&1 | tee $tmp)

if [ -z "$result" ]; then
	echo
	echo "gsman:"${E}" No documentation found for ${1}!"${X}
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