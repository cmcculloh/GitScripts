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
#
#	@file varsreset.sh
## */


# Default answers
export clearscreenanswer="n"
export pushanswer="y"
export checkoutforbranchanswer="y"

# Flagged Actions defaults
export REPLACE_MOTD=true
export USE_GS_PROMPT=true
export IMPORT_BASHMARKS=true
export IMPORT_GIT_ALIASES=true

# Native Git variables
export GIT_MERGE_AUTOEDIT=""

# other default booleans
export showremotestate="n"
export autopushnewbranch=false

# Bash colors
export CFG_NORM=""
export CFG_BRIGHT=""
export CFG_DIM=""
export CFG_BLACK=""
export CFG_RED=""
export CFG_GREEN=""
export CFG_YELLOW=""
export CFG_BLUE=""
export CFG_MAGENTA=""
export CFG_CYAN=""
export CFG_WHITE=""
export CFG_BG_BLACK=""
export CFG_BG_RED=""
export CFG_BG_GREEN=""
export CFG_BG_YELLOW=""
export CFG_BG_BLUE=""
export CFG_BG_MAGENTA=""
export CFG_BG_CYAN=""
export CFG_BG_WHITE=""
export STYLE_BRIGHT=""
export STYLE_NORM=""
export STYLE_DIM=""
export COL_RED=""
export COL_GREEN=""
export COL_YELLOW=""
export COL_BLUE=""
export COL_MAGENTA=""
export COL_CYAN=""
export COL_WHITE=""
export COL_NORM=""
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
export STYLE_BRANCH_WARNING=""
export STYLE_NEWBRANCH_WARNING=""
export STYLE_OLDBRANCH_WARNING=""
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
export H1=""
export H1B=""
export H2=""
export H2B=""
export WB=""
export WNB=""
export WOB=""
export A=""
export B=""
export E=""
export I=""
export O=""
export Q=""
export W=""
export X=""
export STYLE_MENU_HL=""
export STYLE_MENU_INDEX=""
export STYLE_MENU_OPTION=""
export STYLE_MENU_PROMPT=""
export STYLE_PROMPT_DATE=""
export STYLE_PROMPT_PATH=""
export STYLE_PROMPT_PATH_BRANCH=""
export STYLE_PROMPT_BRANCH=""
export STYLE_PROMPT_USER=""

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
