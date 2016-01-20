## /*
#	@description
#	This file is the main controller for all GitScripts. It loads the necessary environment
#	variables, aliases, and scripts that make GitScripts do it's thing. In order for
#	GitScripts to functions properly, you must source this file from your ~/.bashrc,
#	~/.bash_profile, or some other script that loads automatically when you open your
#	CLI.
#
#	Since this file is under source control, you should not make changes to it that you
#	wish to persist. Instead, COPY (since it is also source-controlled) the contents of
#	the cfg/user.overrides.example file into cfg/user.overrides (which you must create)
#	and edit it to your heart's content.
#	description@
#
#	@notes
#	- The user.overrides file is loaded BEFORE the gs.cfg file so that other variables
#	that use previously defined variables in their definition are defined according to
#	user changes. This is because all variables defined in gs.cfg first check for the
#	existence of a variable before defining it.
#	notes@
#
#	@dependencies
#	cfg/vars.cfg
#	dependencies@
#
#	@file _gsinit.sh
## */


# determine the path to this script. it will become the gitscripts path. the cfg directory
# must live in the same directory as this script for any user overrides to take effect.
SCRIPT_PATH="${BASH_SOURCE[0]}"
if [ -h "${SCRIPT_PATH}" ]; then
	while [ -h "${SCRIPT_PATH}" ]; do
		SCRIPT_PATH=`readlink "${SCRIPT_PATH}"`
	done
fi
pushd . > /dev/null
cd `dirname ${SCRIPT_PATH}` > /dev/null
export SCRIPT_PATH=`pwd`;
export gitscripts_path="${SCRIPT_PATH}/"
popd  > /dev/null
export gitscripts_cfg_path="${gitscripts_path}cfg/"





# ensure all submodules are initialized and updated
fshSourceme="${gitscripts_path}/lib/functionsh/SOURCEME"
if [ ! -f "${fshSourceme}" ]; then
    cd "$gitscripts_path"
    git submodule update --init &> /dev/null
fi
if [ ! -f "${fshSourceme}" ]; then
    echo "${E} ERROR: ${X} could not initialize \`functionsh\` library."
    return 2
fi


# source all functions (including libraries)
source "$fshSourceme" > /dev/null
if ! type -t __source_all &> /dev/null; then
    echo "${E} ERROR: ${X} Unable to load dependency libraries."
    return 4
fi
__source_all -x "${gitscripts_path}/functions"
unset fshSourceme


# set up variables to distinguish environment. thanks functionsh!
__get_env


source "${gitscripts_cfg_path}colors.cfg"



# load user overrides.
if [ -f "${gitscripts_cfg_path}user.overrides" ]; then
	echo "gitscripts_cfg_path: ${gitscripts_cfg_path}"
	echo "Will source: ${gitscripts_cfg_path}user.overrides"
	source "${gitscripts_cfg_path}user.overrides"
fi


# load gitscripts variables config. fail if vars config can't be found.
if [ -s "${gitscripts_cfg_path}vars.cfg" ]; then
	source "${gitscripts_cfg_path}vars.cfg"
else
	echo "GitScripts could not load it's main configuration file (cfg/vars.cfg) because it is missing or empty."
	exit 1
fi


# load other foundational files. The order here is intentional! see files for documentation.
# note: you will have to re-define any of your personal aliases which conflict with GitScripts aliases
#	sometime AFTER your have sourced this file (_gsinit.sh). The cfg/user.overrides will NOT work for aliases.
source "${gitscripts_cfg_path}colors.cfg"
source "${gitscripts_lib_path}source_files.sh"
source "${gitscripts_cfg_path}completion.cfg"
source "${gitscripts_cfg_path}flagged_actions.cfg"
source "${gitscripts_cfg_path}aliases.cfg"
#source "${gitscripts_cfg_path}"
