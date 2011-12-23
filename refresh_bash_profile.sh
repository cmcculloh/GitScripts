#!/bin/bash

STYLE_NORM=$'\033[0;30;39m'

echo ${STYLE_NORM}"Preparing to refresh your bash profile..."

touch "${gitscripts_path}bash_profile_config.overrides"
touch "${gitscripts_path}environment_config.overrides"

echo "gitscripts_path: ${gitscripts_path}"

source "${gitscripts_path}environment_config.overrides"
source "${gitscripts_path}environment_config.default"
source "${gitscripts_path}environment_config.overrides"
source "${gitscripts_path}bash_profile_config.overrides"
source "${gitscripts_path}bash_profile_config"

echo "	> concatenating scripts..."
cat "${gitscripts_path}environment_config.overrides" "${gitscripts_path}line_break" "${gitscripts_path}environment_config.default" "${gitscripts_path}line_break" "${gitscripts_path}bash_profile_config.overrides" "${gitscripts_path}line_break" "${gitscripts_path}bash_profile_config" > "${gitscripts_temp_bash_profile_path}"


#/home/csc/Development/workspaces/ubuntu_galileo_workspace/gitscripts/gitscripts_bash_profile

#touch "${native_gitscripts_bash_profile_path}"
#touch "${native_gitscripts_bash_motd_path}"

cp -p -f "${gitscripts_temp_bash_profile_path}" "${native_gitscripts_bash_profile_path}"
cp -p -f "${gitscripts_motd_path}" "${native_motd_path}"

rm "${gitscripts_temp_bash_profile_path}"


echo "	> sourcing: set-bash-colors.sh && bashmarks.sh"
source ${gitscripts_path}set-bash-colors.sh
source ${gitscripts_path}bashmarks.sh

${STYLE_NORM}

echo "	> sourcing: ${native_bash_profile_path}"
source "${native_bash_profile_path}"


## ADDED BY SMOLA ##

	#prevent saving of *.orig files during git diff
git config --global mergetool.keepBackup false

	#some vars
export workspacedir="/d/workspaces/helios_workspace"
export myscriptsdir="${workspacedir}/myscripts"

	#added scripts
unalias branch; alias branch="${gitscripts_path}grepbranch.sh"
alias finddocs="${myscriptsdir}/finddocrefs.sh"
alias getdirs="${myscriptsdir}/getdirs.sh"
alias promosetup="${myscriptsdir}/promosetup.sh"

alias mastermerges="${myscriptsdir}/checkoutbranches.sh"
alias cleanbranches="${myscriptsdir}/cleanbranches.sh"
alias switchenv="${myscriptsdir}/switchenvironment.sh"
alias whichenv="${myscriptsdir}/whichenvironment.sh"

echo
echo ${TEXT_BRIGHT}"Your bash profile has been refreshed!"${X}
echo
echo
