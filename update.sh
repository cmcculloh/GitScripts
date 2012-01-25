#!/bin/bash
## /*
#	@usage update
#
#	@description
#	This script brings your local working branch copy up to date with
#	it's remote branch and master
#	description@
#
#	@notes
#	notes@
#
#	@examples
#	1) update
#	examples@
#
#	@dependencies
#	functions/1000.parse_git_branch.sh
#	functions/1000.set_remote.sh
#	functions/5000.merge_master.sh
#	dependencies@
#
#	@file merge.sh
## */
$loadfuncs


git fetch --all
__set_remote
cb=$(__parse_git_branch)
git pull ${_remote} $cb
git pull ${_remote} master
git status
echo "push? y (n)"
read push
if [ "$push" = "y" ]; then
	git push ${_remote} $cb
fi 