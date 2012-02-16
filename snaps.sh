#!/bin/bash
## /*
#	@usage snaps [--dest=<server1[,server2 [, ...]]>]
#
#	@description
#	When files need to be uploaded to one or more servers, use this script
#	to export changes from the branches currently checked out on fl and
#	flmedia. This script is basically a wrapper for ANT scripts that can
#	be called individually:
#
#	snapshot                This task checks out master and takes a "snapshot" of
#	.                       the files, touching their timestamps to a past date.
#	devexportchanges        Export files newer than 3:00am today to dev.
#	qaexportchanges         Export files newer than 3:00am today to qa.
#	stagingexportchanges    Export files newer than 3:00am today to staging.
#
#	The exported files are sent to:
#	${workspace_path}builds/build/front-end/exports/<server>
#
#	For convenience, the script will also prompt you to delete all files
#	from the export folders before beginning the export. This is the same
#	as running the alias "wipeoutallexports".
#	description@
#
#	@options
#	--dest=<server(s)    Specify one or more servers (separated by commas)
#	.                    You want the files exported to. Options are:
#	.                    all,dev,qa,stage,staging
#	options@
#
#	@notes
#	- Specifying "all" along with any other server is the same as calling "all"
#	by itself.
#	- The dests "stage" and "staging" mean the same thing. The latter is
#	included for ease of use.
#	notes@
#
#	@examples
#	1) snaps
#	# same as calling snaps --dest=all
#
#	2) snaps --dest=qa,stage
#	# export files to the qa and staging exports folders
#
#	3) snaps --dest=qa, stage
#	# this will error as snaps sees two arguments. can use --dest="qa, stage" instead.
#	examples@
#
#	@dependencies
#	gitscripts/functions/0100.bad_usage.sh
#	gitscripts/functions/0500.show_tree.sh
#	gitscripts/functions/1000.parse_git_branch.sh
#	gitscripts/functions/5000.parse_git_status.sh
#	dependencies@
## */
$loadfuncs
$flloadfuncs


echo ${X}

if [ $# -le 1 ]; then

	# validate passed parameter
	if [ -n "$1" ]; then
		if ! grep -q '^--dest=' <<< "$1"; then
			__bad_usage snaps "Parameter not recognized."
			exit 1
		else
			serverstring="${1:7}"

			grep -q 'all' <<< "$serverstring" && all=true || {
				grep -q 'dev' <<< "$serverstring" && dev=true
				grep -q 'qa' <<< "$serverstring" && qa=true
				egrep -q 'stage|staging' <<< "$serverstring" && stage=true
			}

			if [ ! $all ] && [ ! $dev ] && [ ! $qa ] && [ ! stage ]; then
				echo ${E}"  Server destination not recognized.  Aborting...  "${X}
				exit 1
			fi

		fi
	else
		all=true
	fi

else
	__bad_usage snaps "Too many parameters specified."
	exit 1
fi

declare -a servers
declare -a names

[ $all ] && {
	echo "Adding ${COL_GREEN}dev${X} build to command list..."
	servers[0]="ant ${ANT_ARGS} export-changed-by-day -buildfile ${builds_path}dev-front-end.build.xml ;"
	names[0]="dev"
	echo "Adding ${COL_GREEN}qa${X} build to command list..."
	servers[1]="ant ${ANT_ARGS} export-changed-by-day -buildfile ${builds_path}qa-front-end.build.xml ;"
	names[1]="qa"
	echo "Adding ${COL_GREEN}stage${X} build to command list..."
	servers[2]="ant ${ANT_ARGS} export-changed-by-day -buildfile ${builds_path}staging-front-end.build.xml ;"
	names[2]="stage"
} || {
	[ $dev ] && echo "Adding ${COL_GREEN}dev${X} build to command list..." && servers[0]="ant ${ANT_ARGS} export-changed-by-day -buildfile ${builds_path}dev-front-end.build.xml ;" && names[0]="dev"
	[ $qa ] && echo "Adding ${COL_GREEN}qa${X} build to command list..." && servers[${#servers[@]}]="ant ${ANT_ARGS} export-changed-by-day -buildfile ${builds_path}qa-front-end.build.xml ;" && names[${#names[@]}]="qa"
	[ $stage ] && echo "Adding ${COL_GREEN}stage${X} build to command list..." && servers[${#servers[@]}]="ant ${ANT_ARGS} export-changed-by-day -buildfile ${builds_path}staging-front-end.build.xml ;" && names[${#names[@]}]="stage"
}


# get branches to be exported to give user the option to back out.
# will only continue if both branches are clean.
eval "cd ${finishline_path}"
flbranch=$(__parse_git_branch)
__parse_git_status clean || {
	echo
	echo ${E}"  Please clean \`${flbranch}\` on fl and run snaps again. Aborting...  "${X}
	exit 1
}
eval "cd ${media_path}"
flmediabranch=$(__parse_git_branch)
__parse_git_status clean || {
	echo
	echo ${E}"  Please clean \`${flmediabranch}\` on flmedia and run snaps again. Aborting...  "${X}
	exit 1
}


echo
echo
echo "The following branches are currently set to have their changes exported:"
echo "     fl:  ${B}\`${flbranch}\`"${X}
echo "flmedia:  ${B}\`${flmediabranch}\`"${X}
echo
echo ${Q}"Do you want to continue? (y) n"${X}
read yn
echo
if [ -n "$yn" ] && [ "$yn" != "y" ] && [ "$yn" != "Y" ]; then
	echo "You're the boss. Aborting..."
	exit 0
fi


# prompt to wipeout exports folder
echo
echo ${Q}"Would you like to ${A}delete${Q} all files in each of the"
echo "exports folders before beginning this new export? (y) n"${X}
read yn
echo

if [ -z "$yn" ] || [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
	echo ${O}${H2HL}
	echo "  Wiping out all exports...  "
	echo ${H2HL}${X}
	echo
	sleep 1
	ant ${ANT_ARGS} all-wipeout-exports -buildfile "${builds_path}"all-front-end.build.xml;
	echo
fi

# touch file times in master back. already on flmedia!!
echo
echo "${A}Checkout${X} ${B}\`master\`${X} on ${COL_GREEN}flmedia${X} and ${COL_GREEN}fl${X},"
echo "${A}pull${X} down any updates, and ${A}touch${X} file times back. Then ${A}checkout${X}"
echo "original branches."
sleep 3
echo ${O}${H2HL}
echo "$ git checkout master"
git checkout master
echo ${O}
echo
echo "$ git pull flmedia master"
git pull flmedia master
echo ${O}
echo
echo "$ cd ${finishline_path}"
eval "cd ${finishline_path}"
echo
echo
echo "$ git checkout master"
git checkout master
echo ${O}
echo
echo "$ git pull fl master"
git pull fl master
echo ${O}${H2HL}
echo
echo "Running snapshot ANT task..."${X}
ant ${ANT_ARGS} take-changed-files-snapshot -buildfile "${builds_path}"staging-front-end.build.xml ;
echo ${O}
echo
echo "$ git checkout ${flbranch}"
git checkout "$flbranch"
echo ${O}
echo
eval "cd ${media_path}"
echo "$ git checkout ${flmediabranch}"
git checkout "$flmediabranch"
echo ${H2HL}${X}
echo
echo

# run the ant export tasks
for (( i = 0; i < ${#servers[@]}; i++ )); do
	echo ${O}${H2HL}
	echo "  Now exporting files to ${COL_GREEN}${names[i]}${O}  "
	echo ${H2HL}${X}
	sleep 1
	echo
	eval "${servers[i]}"
	echo
done

# view files? maybe in the future...
echo
echo "Exporting ${COL_GREEN}complete${X}. Would you like to view the exports file tree? (y) n"
read yn
echo

{ [ -z "$yn" ] || [ "$yn" = "y" ] || [ "$yn" = "Y" ]; } && {
	__show_tree "${builds_path}build/front-end/exports" | less
}

echo "Goodbye!"

exit
