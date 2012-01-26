#!/bin/bash
## /*
#	@description
#	This script is called when the --build-index option is passed to the
#	gsman command. It cycles through all paths which have been specified
#	to have gcsommented files in them and creates the help files for those
#	commands and adds them to an index which is easily parsed when a user
#	runs "gsman <command>".
#	description@
#
#	@notes
#	- This script is not intended to be used on it's own.
#	notes@
## */

declare -a paths
paths[0]="${gsman_paths_default}"
paths[1]="${gsman_paths_user}"

docPath="${gitscripts_doc_path}"
tmp="${gitscripts_temp_path}gsmantemp"

echo ${X}
echo ${H1}${H1HL}
echo "  Beginning GSMan index build. Please wait...  "
echo ${H1HL}${X}
echo

for (( i = 0; i < ${#paths[@]}; i++ )); do
	[ $i -eq 1 ] && docPathPrefix="user/" || docPathPrefix=""
	docPath="${docPath}${docPathPrefix}"
	[ ! -d "$docPath" ] && mkdir "$docPath"
	docIndex="${docPath}gsman_index.txt"
	: > "$docIndex"

	for path in ${paths[i]}; do
		echo "Indexing files in: $path"

		for file in "$path"*; do
			if [ ! -d "$file" ]; then
				j=0
				docType=""
				docName=""
				awk -f "${gitscripts_awk_path}gsman_parse.awk" "${file}" > "$tmp"
				if grep -q "_gsinit" "${file}"; then cp "$tmp" "${tmp}2"; fi
				while read line; do
					#echo "$line"
					# first line -- type:...
					if [ $j -eq 0 ]; then
						docType="${line:5}"
						[ -z "$docType" ] && docType="main"
						if [ ! -d "${docPath}${docType}" ]; then
							mkdir "${docPath}${docType}"
						fi

					# second line -- name:...
					elif [ $j -eq 1 ]; then
						docName="${line:5}"
						if [ -n "$docName" ] && [ "$docName" != "source" ]; then
							fileName="${docPath}${docType}/${docName}.txt"
							rFileName="${fileName#${gitscripts_path}}"
							echo -e "${docName}:${rFileName}" >> "$docIndex"
						else
							break
						fi

					# all other lines are the gsman comments
					elif [ -n "$rFileName" ]; then
						[ $j -eq 2 ] && : > "$fileName"
						echo "  $line" >> "$fileName"

					fi

					(( j++ ))
				done <"$tmp"
			fi
		done

	done

done

# clean up
rm "$tmp"

exit
