## /* @function
#	@usage __clear
#
#	@description
#	Gives the user an option to clear screen. Will check for the variable $clearscreenanswer
#	to alter the default answer. This variable can be set in user.overrides.
#	description@
#
#	@file functions/0600.clear.sh
## */
function __clear {
	echo
	if [ "$clearscreenanswer" == "n" ] || [ "$clearscreenanswer" == "N" ]; 	then
		defO=" y (n)"
		defA="n"
	else
		defO=" (y) n"
		defA="y"
	fi

	echo ${Q}"${A}Clear${Q} screen?"${defO}${X};
	read yn

	if [ -z "$yn" ]; then
		yn=$defA
	fi

	if [ "$yn" == "y" ] || [ "$yn" == "Y" ]; then
		clear
	fi
}
