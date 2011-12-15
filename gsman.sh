#!/bin/bash

## /*
#
#	This script acts as the controller for the GitScripts Help "gsman" command. It
#	checks for arguments and passes control on to the appropriate script(s) based on those
#	arguments. Associated scripts:
#
#		gsman_parse.sh		Parses a single file for gsman comments/tags.
#
## */

case $# in

	0)
		echo "no arguments"
	;;

	1)
		"${gitscripts_path}gsman_parse.sh" $1
	;;

	*)
		echo "2+ arguments"
	;;

esac
