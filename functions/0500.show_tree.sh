## /* @function
#	@usage __show_tree <path>
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
#	1) __show_tree ~/Documents
#	examples@
## */
function __show_tree {
	if [ -z "$1" ]; then
		echo ${E}"  __show_tree: Path expected as first parameter.  "${X}
		return 1
	fi

	if [ -d "$1" ]; then
		local indent="$indent    "
		for entry in `ls $1`; do
			if [ -d "$entry" ]; then
				grep -q '^\.' <<< "$entry" && continue
				echo ${STYLE_BRIGHT}${COL_YELLOW}"${indent}+ ${entry}"${X}
				__show_tree "$entry"
			else
				echo "${indent}- ${entry}"
			fi
		done
	else
		echo ${E}"  __show_tree: Path given is not a directory.  "${X}
		return 1
	fi
}
