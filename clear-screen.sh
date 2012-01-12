#!/bin/bash
## /*
#	@usage clear-screen.sh
#
#	@description
#	Gives the user an option to clear screen. Will check for the variable $clearscreenanswer
#	to alter the default answer. This variable can be set in user.overrides.
#	description@
#
#	@notes
#	- This script is meant to be included in other scripts and not called directly.
#	notes@
## */

echo
if [ "$clearscreenanswer" == "n" ] || [ "$clearscreenanswer" == "N" ]; 	then
	defO=" y (n)"
	defA="n"
else
	defO=" (y) n"
	defA="y"
fi

echo ${I}"Clear screen?"${defO}${X};
read yn

if [ -z "$yn" ]; then
	yn=$defA
fi

if [ "$yn" == "y" ] || [ "$yn" == "Y" ]; then
	clear
fi


exit
