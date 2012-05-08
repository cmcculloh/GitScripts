#!/bin/bash
## /*
#	@description
#	This file is intended to list all of the keywords which have gsman comments
#	associated with them, and will display using "gsman <keyword>".
#	description@
#
#	@notes
#	- This file is not intended to be used by itself.
#	notes@
#
#	@dependencies
#	functions/0300.menu.sh
#	dependencies@
#
#	@file gsman_list.sh
## */
$loadfuncs


flag="gs"
if [ -n "$1" ]; then
	[ "$1" = "all" ] && flag="all"
	[ "$1" = "user" ] && flag="user"
fi

tmp="${gitscripts_temp_path}cmdlist"

declare -a indexes
case $flag in
	gs)
		cat "${gitscripts_doc_path}gsman_index.txt" > "$tmp";;

	user)
		if [ -s "${gitscripts_doc_path}user/gsman_index.txt" ]; then
			cat "${gitscripts_doc_path}user/gsman_index.txt" > "$tmp"
		else
			echo ${E}"  No user index file could be found! Aborting...  "${X}
		fi;;

	all)
		cat "${gitscripts_doc_path}gsman_index.txt" "${gitscripts_doc_path}user/gsman_index.txt" | sort -r > "$tmp";;
esac


# build command array that will get sent to the __menu function
declare -a cmds
while read line; do
	cmds[${#cmds[@]}]=${line%%:*}
done <"$tmp"

# clean up temp file
rm "$tmp"

if __menu --prompt="Choose a command to view it's documentation" "${cmds[@]}"; then
	if [ -n "$_menu_sel_value" ]; then
		echo
		"${gitscripts_path}gsman.sh" "$_menu_sel_value"
	else
		echo
		echo "  Until next time..."
	fi
else
	echo ${E}"  There was an error displaying the gsman commands. Exiting...  "${X}
fi


exit
