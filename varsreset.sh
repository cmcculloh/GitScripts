## /*
#	@usage varsreset
#
#	@description
#	This script resets a handful of vars that should be reset to see changes immediately
#	The intended purpose is for use in development, but it could also be used when
#	running gs_refresh. After the reset, the user can choose to also refresh GitScripts.
#	description@
#
#	@notes
#	- The gitscripts_path variable should not be included as it is determined programmatically
#	by the location of the _gsinit.sh file.
#	notes@
## */

# Colors
export STYLE_ACTION=""
export STYLE_ERROR=""
export STYLE_H1=""
export STYLE_H2=""
export STYLE_OUTPUT=""
export STYLE_INPUT=""
export STYLE_WARNING=""
export STYLE_QUESTION=""
export STYLE_NEWBRANCH_H1=""
export STYLE_OLDBRANCH_H1=""
export STYLE_NEWBRANCH_H2=""
export STYLE_OLDBRANCH_H2=""
export STYLE_OLDBRANCH=""
export STYLE_NEWBRANCH=""
export STYLE_BRANCH=""
export STYLE_BRANCH_H1=""
export STYLE_BRANCH_H2=""
export STYLE_AHEAD=""
export STYLE_BEHIND=""
export STYLE_DELETEDFILE=""
export STYLE_DIRTY=""
export STYLE_MODIFIED=""
export STYLE_NEWFILE=""
export STYLE_RENAMEDFILE=""
export STYLE_STAGED=""
export STYLE_UNTRACKED=""
export STYLE_MENU_HL=""
export STYLE_MENU_INDEX=""
export STYLE_MENU_OPTION=""
export STYLE_MENU_PROMPT=""
export STYLE_PROMPT_DATE=""
export STYLE_PROMPT_PATH=""
export STYLE_PROMPT_PATH_BRANCH=""
export STYLE_PROMPT_BRANCH=""
export STYLE_PROMPT_USER=""
export H1=""
export H1B=""
export H2=""
export H2B=""
export A=""
export B=""
export E=""
export I=""
export O=""
export Q=""
export W=""
export X=""

echo
echo ${O}"GitScripts variables were reset!"${X}
echo
echo ${Q}"Would you like to run ${A}gs_refresh${Q}? (y) n"${X}
read yn

{ [ -z "$yn" ] || [ "$yn" = "y" ] || [ "$yn" = "Y" ]; } && {
	echo
	echo ${O}"Refreshing GitScripts..."${X}
	echo
	source ${gitscripts_path}_gsinit.sh
	echo ${O}"GitScripts refreshed!"${X}
}
