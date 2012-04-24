#!/bin/bash
## /*
#	@usage syncmyapp add <synctree-command>
#	@usage syncmyapp [list|remove]
#
#	@description
#	This script will look in a given commands source file for
#	sync paths using the synctree command. Choosing no option will
#	copy the files from your project into the jboss war(s).For
#	each individual project, the commands source file must be
#	updated based on the work currently being done.
#
#	Choosing the "list" command outputs the contents of the current sync list.
#	Choosing the "remove" command outputs a menu allowing you to remove a
#	command from the list.
#	description@
#
#	@notes
#	- Commands must be compatible with synctree. Run `gsman synctree` for
#	more information.
#	notes@
#
#	@examples
#	1) syncmyapp add -a storelocator/storelocator.jsp      # single file
#	2) syncmyapp add -m landing-pages/nike-tees            # a directory
#	3) syncmyapp                                           # execute commands
#	examples@
#
#	@dependencies
#	gitscripts/path/to/file
#	dependencies@
## */
$loadfuncs

echo ${X}

cmdsFile="${inputdir}syncmyapp"
touch "$cmdsFile"
echo "in: "`pwd`

case "$1" in
	"add")
		shift
		if grep -q '^-' <<<"$@"; then
			if ! grep -q "$@" "$cmdsFile"; then
				echo "  ${A}Adding${X} $@"
				echo "$@" >> "$cmdsFile"
			else
				echo ${W}"  Command already exists in list. Aborting...  "${X}
				exit 1
			fi
		else
			echo ${E}"  Commands must be compatible with \`synctree\`. Add command as  "
			echo "  you would use it with \`synctree\` WITHOUT using the word 'synctree'."
			echo "    ex: -a global/promos/adidas-shoes"${X}
			exit 1
		fi
		;;

	"list")
		echo ${O}${H2HL}
		echo "  Current list of to \`synctree\` commands:  "
		echo ${H2HL}
		echo
		cat "$cmdsFile" | sort
		echo
		;;

	"remove")
		declare -a cmds
		while read line; do
			cmds[${#cmds[@]}]="$line"
		done <"$cmdsFile"
		if __menu --prompt="Choose a command to remove" "${cmds[@]}"; then

			#create new list in temporary file...
			if [ -n "$_menu_sel_value" ]; then
				: > "$tmp"
				i=0
				while read line; do
					if (( ++i != $_menu_sel_index )); then
						echo "$line" >> "$tmp"
					fi
				done <"$cmdsFile"

				# copy new list to commands file and delete temp list..
				cp -f "$tmp" "$cmdsFile"
				: > "$tmp"

				echo
				echo ${STYLE_BRIGHT}${COL_GREEN}"  Command removed!  "

			fi

		fi
		;;

	*)
		if [ -n "$1" ]; then
			__bad_usage syncmyapp
			exit 1
		fi
		cat "$cmdsFile" | awk '/^-/ { print $0 }' | xargs -n 2 "${flgitscripts_path}synctree.sh"
		echo
		echo ${COL_GREEN}"Sync complete!"${X}
		;;
esac


exit
