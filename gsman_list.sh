#!/bin/bash

# Move through all specified directories and look for gsman comments.
# Find possible files in possible directories.
echo
echo ${O}"Searching files. Please wait..."
echo

both_paths="${gsman_paths_default} ${gsman_paths_user}"
file_list=""
tmp="${gitscripts_temp_path}tmp"
cat /dev/null > $tmp

for gsman_path in $both_paths; do
	echo "  IN: $gsman_path"
	for listing in `ls -p "$gsman_path" | grep -v '/' | egrep "$1\\.[_[:alnum:]]+$"`; do
		# gsman comments should be near the top of the page. we'll give it the first 5
		# just to be safe.
		if { head -5 "${gsman_path}$listing" | egrep -q "##[[:blank:]]*\\/[[:blank:]]*"; }; then
			# conditional eliminates excessive spaces
			name=$(echo $listing | awk '{ gsub(/\.[_a-zA-Z0-9]+$/,""); print }')
			echo $name >> $tmp
			[ -z "$file_list" ] && { file_list="$name"; } || {
				file_list="${file_list} $name"
			}
		fi
	done
done
file_list=$(cat $tmp | sort)
file_array=( $file_list )

# If there is more than one file in the array, user should get a choice of which to view.
num=0
echo
echo ${H2HL}
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

"${gitscripts_path}gsman.sh" $file
