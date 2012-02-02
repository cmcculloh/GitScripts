## /* @function
#	@usage show-tree <path>
#
#	@output true
#
#	@description
#	Show a file tree using indents and colors.
#	description@
#
#	@notes
#	- Dot folders are ignored by default.
#	notes@
#
#	@examples
#	1) show-tree ~/Documents
#	examples@
#
#	@file functions/0500.showtree.sh
## */
function show-tree {
	if [ -z "$1" ]; then
		echo ${E}"  show-tree: Path expected as first parameter.  "${X}
		return 1
	fi

	if [ -d "$1" ]; then
		local indent="$indent    "
		for entry in `ls $1`; do
			if [ -d "$entry" ]; then
				grep -q '^\.' <<< "$entry" && continue
				echo ${STYLE_BRIGHT}${COL_YELLOW}"${indent}+ ${entry}"${X}
				show-tree "$entry"
			else
				echo "${indent}- ${entry}"
			fi
		done
	else
		echo ${E}"  show-tree: Path given is not a directory.  "${X}
		return 1
	fi
}
