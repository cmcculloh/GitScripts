## /*
#	@description
#	This file is sourced and subsequently sources all files in a given directory.
#	description@
#
#	@notes
#	- The asterisk is outside of the quotes so that it expands as a wildcard.
#	notes@
## */
for file in "${gitscripts_functions_path}"*; do

	if [ ! -d "$file" ] && [ -s "$file" ]; then
		source $file
	fi

done