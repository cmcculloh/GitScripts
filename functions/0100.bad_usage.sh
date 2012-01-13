## /*
#	@usage __bad_usage [options] [command_name [message]]
#
#	@output true
#
#	@description
#	Makes error messages a little easier to read. They are prefixed with the command name,
#	include coloring, and direct the user to use the GS Manual. However, if the user wishes
#	to use this function with a command that has no gsman entry, option -o can be used
#	and the reference to the gsman entry will be omitted.
#	description@
#
#	@options
#	-o	Omit the reference to gsman for usage instructions. If this option is given, only the
#		command_name is used. Any further parameters are ignored.
#	options@
#
#	@notes
#	- A message cannot be given without a command name.
#	notes@
#
#	@examples
#	1) __bad_usage checkout "That branch name does not exist."
#		>> checkout: That branch name does not exist. Use "gsman checkout" for usage instructions.
#	2) __bad_usage -o merge
#		>> merge: Invalid usage.
#	3) __bad_usage
#		>> Error: Invalid usage. Use "gsman <command>" for usage instructions.
#	examples@
## */
function __bad_usage {
	# custom __bad_usage function for gitscript commands which implement gsman comments
	#	$1 - command name (optional)
	#	$2 - custom message (optional)
	hcolor=${COL_MAG}

	case $# in
		1)
			# 1st argument MUST be script/command name which has NO spaces and is not an option (-o)
			local space=$(echo $1 | grep '[- ]')
			if [ -n "$space" ]; then
				echo ${hcolor}"__bad_usage: Invalid usage."${X}" Use \""${hcolor}"gsman gsfunctions"${X}"\" for usage instructions."
				fun="gsfunctions"
			else
				echo ${hcolor}"${1}: "${X}"Invalid usage. Use \""${hcolor}"gsman ${1}"${X}"\" for usage instructions."
				fun="${1}"
			fi
			;;

		2)
			if [ "$1" == "-o" ]; then
				# 2nd argument MUST be script/command name which has NO spaces
				local space=$(echo $2 | grep '[ ]')
				if [ -n "$space" ]; then
					echo ${hcolor}"__bad_usage: Invalid usage."${X}" Use \""${hcolor}"gsman gsfunctions"${X}"\" for usage instructions."
					fun="gsfunctions"
				else
					echo ${hcolor}"${2}: "${X}"Invalid usage."
					fun="gsfunctions"
				fi
			else
				echo ${hcolor}"${1}: "${X}"${2} Use \""${hcolor}"gsman ${1}"${X}"\" for usage instructions."
				fun="${1}"
			fi
			;;

		3)
			if [ "$1" == "-o" ]; then
				echo ${hcolor}"${2}: "${X}"${3}"
				fun="gsfunctions"
			else
				echo ${hcolor}"__bad_usage: Invalid usage."${X}" Use \""${hcolor}"gsman gsfunctions"${X}"\" for usage instructions."
				fun="gsfunctions"
			fi
			;;

		*)
			echo "Error: Invalid usage. Use \""${hcolor}"gsman <command>"${X}"\" for usage instructions."
			fun="gsfunctions"
			;;
	esac

	echo
	echo "Run gsman $fun? y (n)"
	read yn
	if [ "$yn" = "y" ]
		then
		"${gitscripts_path}"gsman.sh "$fun"
	fi
}