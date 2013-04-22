## /* @function
#	@usage __merge_master
#
#	@output false
#
#	@description
#	Merges remote/master into the current branch. Should be tied to
#	an alias "mergemaster"
#	description@
#
#	@notes
#	notes@
#
#	@examples
#	# ...
#		__merge_master
#	#...
#	examples@
#
#	@dependencies
#	functions/1000.set_remote.sh
#	dependencies@
#
#	@file functions.5000.merge_master.sh
## */
function __merge_master {
	__set_remote
	echo ${Q}"${A}Merge${Q} branch ${B}\`${_remote}/master\`${Q} into ${B}\`${branch}\`${Q}? (y) n"${X}
	read decision

	if [ -z "$decision" ] || [ "$decision" = "y" ] || [ "$decision" = "Y" ]; then
		echo
		echo "${A}Merging${X} ${B}\`${_remote}/master\`${X} into ${B}\`${branch}\`${X} ..."
		echo ${O}${H2HL}
		echo "$ git merge --ff ${_remote}/master"
		git merge --ff "${_remote}/master"
		echo ${O}
		echo
	else
		echo
		echo ${O}${H2HL}
	fi
}
