## /* @function
#	@usage flgs-config-search <key>
#
#	@output false
#
#	@description
#	Searches the flgs.config file for the existence of the given key. It does not matter
#	whether or not the key has an associated value.
#	description@
#
#	@notes
#	-Intended for use with conditionals as return values are specified.
#	notes@
#
#	@examples
#	# some operations may include uploading/downloading via (s)ftp
#	if flgs-config-search ftp.user; then
#	    user=$(flgs-config get ftp.user)
#	    # interact with ftp...
#	fi
#	examples@
#
#	@dependencies
#	functions/1000.flgs-config-exists.sh
#	gitscripts/functions/0200.gslog.sh
#	dependencies@
#
#	@file functions/1100.flgs-config-search.sh
## */
function flgs-config-search {
	if [ -n "$1" ]; then
		if flgs-config-exists; then
			# search for key.
			cat "$flgitscripts_config" | grep -q "^${1}="
			return $?
		else
			__gslog "flgs-config-search: No config file found to search for key: $key"
			return 1
		fi
	else
		__gslog "flgs-config-search: No search key given! "${X}
		return 1
	fi
}
