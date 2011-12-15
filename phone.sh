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
#	gitscripts/awkscripts/phone.awk
#	gitscripts/input/_phoneList
#	dependencies@
## */


hcolor=${COL_MAG}

case $# in

	1)
		#search string given. default processing.
	;;

	2)
		#parse option(s)
		case $1 in
			"-i")
				if [ ! -f $2 ]; then
					echo ${hcolor}"phone: "${X}"Given file path appears to be invalid. "${hcolor}"phone"${X}". Use \""${hcolor}"gsman phone\""${X}" for usage instructions."
					exit 1
				fi

				#make sure the function is available if a word doc is given
				filex=$(echo $2 | grep '')
				okstrings=$(which strings)

			;;

			*)
				echo ${hcolor}"phone: "${X}"Invalid option specified. Use \""${hcolor}"gsman phone\""${X}" for usage instructions."
				exit 1
	;;

	*)
		echo ${hcolor}"phone: "${X}"Invalid usage. Use \""${hcolor}"gsman phone\""${X}" for usage instructions."
		exit 1
	;;

esac
if [ $# ]; then

fi

list="${inputdir}_phoneList"
cat $list | awk -v name="$1" -f "${awkdir}phone.awk"