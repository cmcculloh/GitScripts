## /*
#	@usage __flgs_config_exists
#
#	@output false
#
#	@description
#	Shortcut for testing that the file exists and is non-empty.
#	description@
#
#	@notes
#	- Meant for use in conditionals.
#	notes@
#
#	@examples
#	# get the value associated with "mykey" in the config file
#	__flgs_config_exists && myvar=`flgs_config mykey`
#	examples@
#
#	@file functions/1000.__flgs_config_exists.sh
## */
function __flgs_config_exists {
	[ -s "${flgitscripts_config}" ]
}