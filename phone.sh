#!/bin/bash

## /*
#	@usage phone <term>
#
#	@description
#	Searches the phone list in the input folder for the specified string.
#	First/Last names as well as phone extensions are searchable. Name and
#	extension are output to screen.
#	description@
#
#	@notes
#	- Search terms are case-insensitive.
#	- To search first and last name concurrently, enclose term in quotes.
#	notes@
#
#	@examples
#	1) phone chris
#	2) phone "chris s"
#	examples@
#
#	@dependencies
#	gitscripts/gsfunctions.sh
#	gitscripts/awkscripts/phone.awk
#	gitscripts/input/_phoneList
#	dependencies@
## */
$loadfuncs


hcolor=${COL_MAG}

function update_list {
	echo
}


case $# in
	1)
		#search string given. default processing.
		if [ "$1" == "-u" ]; then
			update_list
		else
			query="$1"
		fi
		;;

	2)
		#parse option(s)
		case $1 in
			"-u")
				update_list
				query="$2"
				;;

			*)
				__bad_usage phone "Invalid option specified."
				exit 1
				;;
		esac
		;;

	*)
		__bad_usage phone
		exit 1
		;;
esac


list="${inputdir}_phoneList"
cat $list | awk -v name="$query" -f "${awkdir}phone.awk"