## /*
#	@usage flpullscripts
#
#	@description
#	Run this command to simultaneously update flgitscripts and the
#	GitScripts submodule hash.
#	description@
#
#	@notes
#	- The alias _sources_ this file so that running refresh_bash_profile updates
#	any variable references that were updated in the pull.
#	notes@
#	@dependencies
#	gitscripts/functions/5000.parse_git_status.sh
#	refresh_bash_profile.sh
#	dependencies@
#
#	@file flpullscripts.sh
## */
$loadfuncs


echo ${X}
echo ${H1}${H1HL}
echo "  Updating scripts...  "
echo ${H1HL}${X}
echo
echo


# save current path
pushd . > /dev/null

cd "${flgitscripts_path}" > /dev/null

if __parse_git_status clean; then
	echo ${O}
	echo "$ git fetch --all --prune"
	git fetch --all --prune
	echo
	echo

	echo "${A}Checkout${X} ${B}\`master\` and then ${A}pull${X} in updates."
	echo ${O}${H2HL}
	echo "$ git checkout master"
	git checkout master
	echo ${O}
	echo
	echo "$ git pull origin master"
	git pull origin master
	echo ${O}${H2HL}${X}
	echo
	echo
	echo "${A}Updating${X} the GitScripts submodule..."
	echo ${O}${H2HL}
	echo "$ git submodule update"
	git submodule update
	echo ${O}${H2HL}${X}
	echo
	echo
	source refresh_bash_profile.sh
	echo
	echo ${COL_GREEN}"FLpullscripts complete!"${X}
else
	echo ${E}"  Please make sure your flgitscripts_path is clean before running flpullscripts again.  "
	echo "  Aborting..."${X}
fi

popd > /dev/null

# no exit command since this file should be sourced
