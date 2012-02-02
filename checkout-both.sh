#!/bin/bash
## /*
#	@usage checkoutboth <branch-name>
#
#	@description
#	A shortcut to checking out a branch on both fl and flmedia.
#	description@
#
#	@notes
#	- There are no checks for branch existence. This will be handled
#	in the checkout.sh script calls.
#	notes@
#
#	@examples
#	1) checkoutboth master
#	examples@
#
#	@dependencies
#	checkout.sh
#	gitscripts/functions/0100.bad_usage.sh
#	dependencies@
## */
$loadfuncs


echo ${X}

if [ -z "$1" ]; then
	__bad_usage checkoutboth "Branch name required."
	exit 1
fi

branch="$1"

echo ${H1}${H1HL}
echo "  Checking out branch ${H1B}\`$1\`${H1} for media...  "
echo ${H1HL}${X}
echo
eval "cd ${media_path}"
"${gitscripts_path}"checkout.sh "$branch";

echo
echo

echo ${H1}${H1HL}
echo "  Checking out branch ${H1B}$1${H1} for fl...  "
echo ${H1HL}${X}
echo
eval "cd ${finishline_path}"
"${gitscripts_path}"checkout.sh "$branch";


exit
