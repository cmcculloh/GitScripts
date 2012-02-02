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
#	awkscripts/phone.awk
#	functions/1000.flgs-config-exists.sh
#	gitscripts/functions/0100.bad_usage.sh
#	input/_phoneList
#	*input/_phoneList.batch
#	dependencies@
## */
$loadfuncs
$flloadfuncs


list="${inputdir}phoneList"
touch $list

function update_list {
	if ! flgs-config-exists; then
		echo ${E}"  Unable to acquire ftp address! Check config settings and try again. "${X}
		return 1
	fi

	local txtfile="${tempdir}numbers.txt"
	local ftpaddr=$(flgs-config get ftp.riddle)
	touch "$txtfile"

	echo
	echo "	Acquiring phone list via sftp..."
	sftp -b "${inputdir}_phoneList.batch" "et@${ftpaddr}" >/dev/null
	if [ -s "$txtfile" ]; then
		cat "$txtfile" | egrep '[-[:blank:]][0-9][0-9][0-9][0-9]$' > "$tmp"
		if [ -s "$tmp" ]; then
			cp "$tmp" "$list"
			echo ${COL_GREEN}"	Phone list has been updated!"${X}
			rm "$txtfile"
			rm "$tmp"
		else
			echo ${E}"	There was a problem parsing the phone list for numbers."${X}
		fi
	else
		echo ${E}"  Unable to acquire updated phone list.  "${X}
	fi
}


case $# in
	1)
		#search string given. default processing.
		if [ "$1" == "-u" ]; then
			update_list
		elif grep -q '^-' <<< "$1"; then
			__bad_usage phone "Unrecognized parameter ($1) given."
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
cat "$list" | awk -v name="$query" -f "${awkscripts_path}phone.awk"

exit
