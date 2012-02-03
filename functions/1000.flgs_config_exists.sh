## /*
#	@usage flgs-config-exists
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
#	flgs-config-exists && myvar=`flgs-config mykey`
#	examples@
#
#	@file functions/1000.flgs-config-exists.sh
## */
function flgs-config-exists {
	[ -s "${flgitscripts_config}" ]
}