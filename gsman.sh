#!/bin/bash
## /*
#	@usage gsman <[options] | [keyword]>
#
#	@description
#	The GitScripts MANual is to GitScripts as the Man Pages are to Unix commands.
#	The information for gsman entries can be as extensive as the user wishes. The
#	gsman essentially looks for files in the gitscripts directory matching the
#	given command name. It then parses those files for gsman comment blocks. These
#	blocks take the form:
#
#		## /* @category (optional)
#		#	@oneLineTag lorem ipsum
#		#
#		#	@tagBlock
#		#	Lorem ipsum blah blah....
#		#	tagBlock@
#		## */
#
#	where the start of the comment is two pound signs (#) followed by a forward
#	slash and asterisk, and the closing of the comment is two pound signs followed
#	by an asterisk and a forward slash. This syntax closesly resembles block-style
#	comments in CSS and other web languages. Tag names begin with the "at" symbol (@)
#	and are followed by one or more letters of the alphabet. Common tags used are:
#
#		@usage		<< This tag MUST be on the first line for the file to be gsman-compatible!
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
#	--build-index[=main|user]    Build the files which are used for outputting gsman comments
#	                             in an easy-to-read format. Also build command index files.
#	                             If "user" is specified, only build the user index/help. If
#	                             "main" is specified, only build the gitscripts core index/help.
#	--list[=user|all),           Show a list of all the files which contain gsman comments
#	                             and are accessible using the gsman command. If "user" is
#	                             specified, only show commands that have been indexed from
#	                             paths set in the $gitscripts_paths_user variable. If "all" is
#	                             specified, show both user AND GitScripts native command lists.
#	-h, --help                   Same as --list.
#	options@
#
#	@notes
#	- The @usage tag MUST be included on the first line (under ## /*) for the comments
#	  to be available in gsman!
#	- If an option is given, omit the keyword. Both should not be used simultaneously.
#	notes@
#
#	@examples
#	1) gsman phone
#	2) gsman --help
#	3) gsman --list=all    # get a list of all commands that have gsman-available help
#	examples@
#
#	@dependencies
#	gsman_build_index.sh
#	gsman_list.sh
#	gsman_parse.sh
#	functions/0100.bad_usage.sh
#	dependencies@
## */
$loadfuncs


case $# in

	# 0)
	# 	__bad_usage gsman
	# 	;;

	1)
		case "$1" in
			"--list" | "-h" | "--help")
				"${gitscripts_path}"gsman_list.sh;;

			"--list=user")
				"${gitscripts_path}"gsman_list.sh user;;

			"--list=all")
				"${gitscripts_path}"gsman_list.sh all;;

			"--build-index")
				"${gitscripts_path}"gsman_build_index.sh;;

			"--build-index="*)
				"${gitscripts_path}"gsman_build_index.sh ${1:14};;

			*)
				"${gitscripts_path}"gsman_parse.sh "$1";;
		esac
		;;

	*)
		__bad_usage gsman
		;;

esac

exit
