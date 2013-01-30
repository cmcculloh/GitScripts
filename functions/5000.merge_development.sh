## /* @function
#	@usage __merge_development
#
#	@output false
#
#	@description
#	Merges remote/development into the current branch. Should be tied to
#	an alias "mergedevelopment"
#	description@
#
#	@notes
#	notes@
#
#	@examples
#	# ...
#		__merge_development
#	#...
#	examples@
#
#	@dependencies
#	functions/1000.set_remote.sh
#	dependencies@
#
#	@file functions.5000.merge_development.sh
## */
function __merge_development {
	__set_remote
	echo ${Q}"${A}Merge${Q} branch ${B}\`${_remote}/development\`${Q} into ${B}\`${branch}\`${Q}? (y) n"${X}
	read decision

	if [ -z "$decision" ] || [ "$decision" = "y" ] || [ "$decision" = "Y" ]; then
		echo
		echo "${A}Merging${X} ${B}\`${_remote}/development\`${X} into ${B}\`${branch}\`${X} ..."
		echo ${O}${H2HL}
		echo "$ git merge ${_remote}/development"
		git merge "${_remote}/development"
		echo ${O}
		echo
	else
		echo
		echo ${O}${H2HL}
	fi
}
