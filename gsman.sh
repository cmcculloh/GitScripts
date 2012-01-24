#!/bin/bash
## /*
#	@usage gsman [options|flags] <required command>
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
#	begin with the "at" symbol (@) and are followed by one or more letters of the alphabet. Common
#	tags used are:
#
#		@usage
#		@file
#		@output
#		@description
#		@options
#		@notes
#		@examples
#		@dependencies
#	description@
#
#	@options
#	-l, --list,	Show a list of all the files which contain gsman comments and are accessible using
#	-h, --help	the gsman command.
#	options@
#
#	@examples
#	1) gsman phone
#	2) gsman --help
#	examples@
#
#	@dependencies
#	gitscripts/gsman_parse.sh
#	gitscripts/gsman_list.sh
#	dependencies@
## */
$loadfuncs

case $# in

	0)
		__bad_usage gsman
	;;

	1)
		case "$1" in
			"-l" | "--list" | "-h" | "--help")
				"${gitscripts_path}gsman_list.sh";;

			*)
				"${gitscripts_path}gsman_parse.sh" $1;;
		esac
	;;

	*)
		echo "2+ arguments"
	;;

esac
