#!/bin/bash
## /*
#	@usage checkout [branch-name]
#
#	@description
#	This script assists with checking out a branch in several ways. Firstly, if you
#	don't know the specific name of the branch for whatever reason, you can omit the
#	branch name as the first parameter to view a list of all branches, even branches
#	on the remote, if any. Secondly, You are automatically prompted to merge master into
#	the branch which you are checking out to keep it current. In addition, safeguards
#	are in place to prevent unnecessary processing if, for instance, you are already
#	on the branch you are trying to checkout or the branch doesn't exist locally,
#	remotely, or at all.
#	description@
#
#
#	@examples
#	1) checkout
#	   # Will show a list of branches available for checkout.
#	2) checkout my-big-project-changes
#	   # checks out my-big-project-changes and will attempt to merge master into it
#	   # or rebase it onto master.
#	examples@
#
#	@dependencies
#	functions/6000.checkout.sh
#	dependencies@
#
#	@file checkout.sh
## */
$loadfuncs

checkout "$@"

exit
