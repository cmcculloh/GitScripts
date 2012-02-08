## /* @function
#	@usage __flgs_config_search <key>
#
#	@output false
#
#	@description
#	Searches the flgs.config file for the existence of the given key. It does not matter
#	whether or not the key has an associated value.
#	description@
#
#	@notes
#	- Intended for use with conditionals as return values are specified.
#	notes@
#
#	@examples
#	# some operations may include uploading/downloading via (s)ftp
#	if __flgs_config_search ftp.user; then
#	    user=$(flgs_config get ftp.user)
#	    # interact with ftp...
#	fi
#	examples@
#
#	@dependencies
#	functions/1000.flgs_config_exists.sh
#	gitscripts/functions/0200.gslog.sh
#	dependencies@
#
#	@file functions/1100.__flgs_config_search.sh
## */
function __flgs_config_search {
	if [ -n "$1" ]; then
		if __flgs_config_exists; then
			# search for key.
			cat "$flgitscripts_config" | grep -q "^${1}="
			return $?
		else
			__gslog "__flgs_config_search: No config file found to search for key (${key})"
			return 1
		fi
	else
		__gslog "__flgs_config_search: No search key given! "${X}
		return 1
	fi
}
