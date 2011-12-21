#!/bin/bash

## /*
#	@usage gsman [options] <command>
#
#	@description
#	The GitScripts MANual is to GitScripts as the Man Pages are to Unix commands.
#	The information for gsman entries can be as extensive as the user wishes. The
#	gsman essentially looks for files in the gitscripts directory matching the
#	given command name. It then parses those files for gsman comment blocks. These
#	blocks take the form:
#
#		## /*
#		#	@oneLineTag lorem ipsum
#		#
#		#	@tagBlock
#		#	Lorem ipsum blah blah....
#		#	tagBlock@
#		## */
#
#	where the start of the comment is two pound signs (#) followed by a forward slash and asterisk,
#	and the closing of the comment is two pound signs followed by an asterisk and a forward slash.
#	This syntax closesly resembles block-style comments in CSS and other web languages. Tag names
#	begin with the "at" symbol (@) and are followed by one or more letters of the alphabet.
#	description@
#
#	@examples
#	1) gsman phone
#	examples@
#
#	@dependencies
#	gitscripts/gsman_parse.sh
#	dependencies@
## */
$loadfuncs

case $# in

	0)
		__bad_usage gsman
	;;

	1)
		"${gitscripts_path}gsman_parse.sh" $1
	;;

	*)
		echo "2+ arguments"
	;;

esac
