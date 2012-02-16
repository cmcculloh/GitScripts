## /*
#	@description
#	This file is to be sourced to load all functions into the calling
#	context. It works just like the $loadfuncs variable in GitScripts.
#	description@
#
#	@examples
#	1) $flloadfuncs
#	examples@
#
#	@file fl-load-funcs.sh
## */
for file in "${flgitscripts_functions_path}"*; do
	if [ ! -d "$file" ] && [ -s "$file" ]; then
		#echo "Going to source: ${file}"
		source "$file"
	fi
done
