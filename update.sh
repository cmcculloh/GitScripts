#!/bin/bash
## /*
#	@usage update
#
#	@description
#	This script brings your local working branch copy up to date with
#	it's remote branch and master.
#
#	This script:
#	1) Fetches all
#	2) Sets your remote
#	3) Pulls the remote version of you current branch
#	4) Pulls the remote master
#	5) Asks if you want to push (and then pushes if so)
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
#	push.sh
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
"${gitscripts_path}"push.sh