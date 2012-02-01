#!/bin/bash

## /*
#	@usage fixbranch <branch_name>
#
#	@description
#	This script expects a string that begins with a ticket number (three capital
#	letters followed by 5 digits) and is followed by zero or more characters. It then
#	performs several operations:
#	description@
#
#	@notes
#	- <branch_name> should ALWAYS be surrounded with quotes to avoid bash conflicts.
#	- A branch name that has already been fixed will simply be returned.
#	notes@
#
#	@examples
#	1) fixbranch "NEW70476: Ya'll enjoy the fireworks..."
#		returns: NEW70476---yall-enjoy-the-fireworks
#	examples@
#
#	@dependencies
#	gitscripts/gsfunctions.sh
#	gitscripts/awkscripts/fixbranch.awk
#	dependencies@
## */
$loadfuncs


if [ -z "$1" ]; then
	__bad_usage fixbranch
	exit 1
fi

result=$(echo "$@" | awk -f "${awkscripts_path}fixbranch.awk")
if [ -z "$result" ]; then
	__bad_usage fixbranch
else
	echo $result
fi