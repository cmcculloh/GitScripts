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

cat "${gitscripts_path}environment_config.overrides" "${gitscripts_path}line_break" "${gitscripts_path}environment_config.default" "${gitscripts_path}line_break" "${gitscripts_path}environment_config.overrides" "${gitscripts_path}line_break" "${gitscripts_path}bash_profile_config.overrides" "${gitscripts_path}line_break" "${gitscripts_path}bash_profile_config" > "${gitscripts_temp_bash_profile_path}"


#/home/csc/Development/workspaces/ubuntu_galileo_workspace/gitscripts/gitscripts_bash_profile

#touch "${native_gitscripts_bash_profile_path}"
#touch "${native_gitscripts_bash_motd_path}"

cp -p -f "${gitscripts_temp_bash_profile_path}" "${native_gitscripts_bash_profile_path}"
#cp "${gitscripts_path}motd" "${native_gitscripts_bash_motd_path}"

rm "${gitscripts_temp_bash_profile_path}"

echo "Going to source: ${native_bash_profile_path}"

source ${gitscripts_path}set-bash-colors.sh
source ${gitscripts_path}bashmarks.sh

${STYLE_NORM}

source "${native_bash_profile_path}"


#source "${native_gitscripts_bash_profile_path}"


echo ""
echo "Refreshed your bash profile."
echo ""
echo ""

