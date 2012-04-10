## /* @function
#	@usage __flgs_config < -l|--list >
#	@usage __flgs_config < --reset[=quiet] >
#	@usage __flgs_config get <key>
#	@usage __flgs_config set <key> <value>
#
#	@output true
#
#	@description
#	This function is used similarly to the git config functionality. The key=value pairs
#	are stored in flgs.config. Values can be retrieved and set using the get and set
#	commands respectively.
#	description@
#
#	@options
#	-l, --list             List all of the current key=value pairs.
#	--reset[=quiet]        Reset config file to default settings. If the "quiet"
#	.                      value is set, all non-error output is suppressed. This
#	.                      includes the confirmation prompt.
#	options@
#
#	@notes
#	- Using the -l or --list options will ignore any other parameters.
#	- When resetting, a backup of the config file is made and placed in
#	the temp/ directory.
#	notes@
#
#	@examples
#	1) __flgs_config get ssh-hosts
#	2) __flgs_config set ftp.user csmola
#	examples@
#
#	@dependencies
#	awkscripts/config-parse-key.awk
#	awkscripts/config-set-value.awk
#	functions/1000.__flgs_config_exists.sh
#	functions/1100.__flgs_config_search.sh
#	gitscripts/functions/0200.gslog.sh
#	dependencies@
#
#	@file functions/1200.__flgs_config.sh
## */
function __flgs_config {
	if ! __flgs_config_exists && ! grep -q '^--reset' <<< "$1"; then
		echo ${E}"  Config file could not be found.  "${X}
		return 1
	fi

	if [ -n "$1" ]; then
		case "$1" in
			# Retrieve a value given a key.
			# Errors are logged since this output is usually captured.
			get)
				if [ -n "$2" ]; then
					if __flgs_config_search "$2"; then
						cat "$flgitscripts_config" | awk -v key="$2" -f "${awkscripts_path}config-parse-key.awk";
						return 0
					else
						__gslog "__flgs_config: Key not found ($2)"
						return 1
					fi
				else
					__gslog "__flgs_config: User did not provide a key to search for!"
					return 1
				fi;;

			# Reset a value to a current key or set a new key=value pair.
			set)
				# As no output is expected, echoing the errors is OK.
				if [ -n "$2" ]; then
					tempfile="${tempdir}config_temp"

					# find key. will need to replace value.
					if __flgs_config_search "$2"; then
						# make sure awk processing errors are caught
						if ! cat "$flgitscripts_config" | awk -v key="$2" -v value="$3" -f "${awkscripts_path}config-set-value.awk" > "$tempfile"; then
							echo ${E}"  Error setting value in awk!  "${X}
						fi

					# key doesn't exist. we will append it to the config.
					else
						cat "$flgitscripts_config" > "$tempfile"
						echo "${2}=${3}" >> "$tempfile"
					fi

					# copy temp config to permanent config
					if cp -f "$tempfile" "$flgitscripts_config"; then
						rm "$tempfile"
						return 0
					else
						echo ${E}"  Unable to copy temporary configuration to permanent config file.  "${X}
						return 1
					fi
				else
					echo ${E}"  A key and value must be given to the set command.  "${X}
					return 1
				fi;;

			# List all of the current key=value pairs.
			"-l" | "--list")
				echo
				cat "$flgitscripts_config"
				echo;;

			"--reset"|"--reset=quiet")
				# do the reset without any output.
				if [ "$1" != "--reset=quiet" ]; then
					echo
					echo ${W}"  WARNING: This action will reset ALL values in the config!  "${X}
					echo
					echo ${Q}"Are you sure you want to continue? y (n)"${X}
					read yn
					echo
					if [ "$yn" != "y" ] && [ "$yn" != "Y" ]; then
						echo "Wise decision. Aborting..."
						return 0
					fi
				else
					local isQuiet=true
				fi

				# make a backup of existing config
				if __flgs_config_exists; then
					[ $isQuiet ] || echo "Backing up config file to temp directory..."
					cp -f "$flgitscripts_config" "${tempdir}flgs.config.bak"
					: > "$flgitscripts_config"
				fi

				# create config file from default
				if [ -s "$flgitscripts_config_defaults" ]; then
					tolog="Creating ${flgitscripts_config} from ${flgitscripts_config_defaults}..."
					# find a way to add gscomment at top?
					cat "$flgitscripts_config_defaults" | egrep '^[^#]' | sort >> "$flgitscripts_config" && {
						__gslog "${tolog}done."
						[ $isQuiet ] || { echo; echo "Config file was successfully reset!"; }
						return 0
					} || {
						__gslog "${tolog}failed!"
						echo ${E}"  __flgs_config: There was an error creating the __flgs_config file from the default!  "${X}
						return 1
					}
				else
					echo ${E}"  __flgs_config: No default config file found!  "${X}
					return 1
				fi;;

			*)
				echo ${E}"  __flgs_config: Unrecognized parameter ($1).  "${X}
				return 1;;
		esac

	else
		echo ${E}"  __flgs_config: You must provide a command to __flgs_config.  "${X}
		return 1
	fi
}
