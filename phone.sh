#!/bin/bash

## /*
#	@usage phone [options] [term]
#
#	@description
#	Searches the phone list in the input folder for the specified string.
#	First/Last names as well as phone extensions are searchable. Name and
#	extension are output to screen.
#	description@
#
#	@options
#	-u	Acquire an updated phone list. This option can be used with or
#		without a search term specified.
#	options@
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


list="${inputdir}phoneList"
touch $list

function update_list {
	local txtfile="${tempdir}numbers.txt"
	touch $txtfile
	echo
	echo "	Acquiring phone list via sftp..."
	sftp -b "${inputdir}_phoneList.batch" et@10.0.30.45 1>/dev/null
	if [ -s "$txtfile" ]; then
		cat $txtfile | egrep '[-[:blank:]][0-9][0-9][0-9][0-9]$' > $tmp
		if [ -s "$tmp" ]; then
			cp $tmp $list
			echo ${COL_GREEN}"	Phone list has been updated!"${X}
			rm $txtfile
			rm $tmp
		else
			echo ${E}"	There was a problem parsing the phone list for numbers."${X}
		fi
	else
		__bad_usage phone "Unable to acquire updated phone list."
	fi
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

#search the list
cat $list | awk -v name="$query" -f "${awkdir}phone.awk"