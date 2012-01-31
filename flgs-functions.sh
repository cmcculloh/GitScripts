
## /* @function
#	@usage flgs-config-search <key>
#
#	@output false
#
#	@description
#	Searches the flgs.config file for the existence of the given key. It does not matter
#	whether or not the key has an associated value.
#	description@
#
#	@notes
#	-Intended for use with conditionals as return values are specified.
#	notes@
#
#	@dependencies
#	gitscripts
#	dependencies@
## */
function flgs-config-search {
	if [ -n "$1" ]; then
		if [ $FLGS_CONFIG ]; then
			# search for key.
			cat $flgitscripts_config | grep -q "^${1}="
			return $?
		else
			__gslog "flgs-config-search: No config file found to search for key> $key"
			return 1
		fi
	else
		__gslog "flgs-config-search: No search key given! "${X}
		return 1
	fi
}


## /*
#	@usage flgs-config [options] <get|set> <key> [value]
#
#	@description
#	This function is used similarly to the git config functionality. The key=value pairs
#	are stored in flgs.config. Values can be retrieved and set using the get and set
#	commands respectively.
#	description@
#
#	@options
#	-l, --list	List all of the current key=value pairs.
#	options@
#
#	@notes
#	- Using the -l or --list options will ignore any other parameters.
#	notes@
#
#	@examples
#	1) flgs-config get ssh-hosts
#	2) flgs-config set ftp.user csmola
#	examples@
#
#	@dependencies
#	gitscripts
#	dependencies@
## */
function flgs-config {
	if [ -n "$1" ]; then
		case "$1" in
			# Retrieve a value given a key.
			get)
				if [ -n "$2" ]; then
					# although not strictly necessary, the conditio
					if [ $FLGS_CONFIG ]; then
						cat $flgitscripts_config | awk -v key="$2" -f "${awkscripts_path}config-parse-key.awk";
					fi
				else
					__gslog "flgs-config: User must provide a key to search for!"
					return 1
				fi;;

			# Reset a value toa  current key or set a new key=value pair.
			set)
				# As no output is expected, echoing the errors is OK.
				if [ -n "$2" ] && [ -n "$3" ]; then
					tempfile="${tempdir}config_temp"
					touch $tempfile
					if flgs-config-search $2; then
						# key found. will need to replace value.
						cat $flgitscripts_config | awk -v key="$2" -v value="$3" -f "${awkscripts_path}config-set-value.awk" > $tempfile

					# the above condition will return false if the config file doesn't exist as well, so make sure it does.
					elif [ $FLGS_CONFIG ]; then
						# key doesn't exist. we will append it to the config.
						cat $flgitscripts_config > $tempfile
						echo "${2}=${3}" >> $tempfile
					else
						echo ${X}" Could not set key=value as config file is missing. "${X}
						return 1
					fi

					# copy temp config to permanent config
					if cp -f $tempfile $flgitscripts_config; then
						rm $tempfile
						return 0
					else
						echo ${E}" Unable to copy temporary configuration to permanent config file. "${X}
						return 1
					fi
				else
					echo ${E}" A key and value must be given to the set command. "${X}
					return 1
				fi;;

			# List all of the current key=value pairs.
			"-l" | "--list")
				if [ $FLGS_CONFIG ]; then
					echo
					cat $flgitscripts_config | egrep "^[[:alpha:]]"
					echo
				fi;;

			*)
				echo ${E}" flgs-config: You must provide a command to flgs-config. "${X}
				return 1;;
		esac

	else
		echo ${E}" flgs-config: You must provide a command to flgs-config. "${X}
		return 1
	fi
}


