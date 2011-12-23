#!/bin/bash

# need to know current path of this file first
SCRIPT_PATH="${BASH_SOURCE[0]}"
if [ -h "${SCRIPT_PATH}" ]; then
	while [ -h "${SCRIPT_PATH}" ]; do
		SCRIPT_PATH=`readlink "${SCRIPT_PATH}"`
	done
fi
pushd . > /dev/null
cd `dirname ${SCRIPT_PATH}` > /dev/null
export SCRIPT_PATH=`pwd`;
export flgitscripts_path="${SCRIPT_PATH}/"
popd  > /dev/null

# user can optionally reset crucial variables. useful for development,
# harmless for normal use.
if [ -n "$1" ] && [ "$1" == "--reset" -o "$1" == "-r" ] && [ -f "${flgitscripts_path}vars_reset.sh" ]; then
	echo
	source "${flgitscripts_path}vars_reset.sh"
fi


echo
echo ${H2}"Running from:  ${flgitscripts_path}"${X}
echo
echo "Preparing to refresh your bash profile..."

touch "${flgitscripts_path}bash_profile_config.overrides"
touch "${flgitscripts_path}environment_config.overrides"

source "${flgitscripts_path}environment_config.overrides"
source "${flgitscripts_path}environment_config.default"

touch "${flgitscripts_temp_bash_profile_path}"
echo "export flgitscripts_path=\"${flgitscripts_path}\"" > $tmp

echo "	> concatenating scripts..."
cat "${tmp}" "${flgitscripts_path}environment_config.overrides" "${flgitscripts_path}line_break" "${flgitscripts_path}environment_config.default" "${flgitscripts_path}line_break" "${flgitscripts_path}bash_profile_config.overrides" "${flgitscripts_path}line_break" "${flgitscripts_path}bash_profile_config.default" > "${flgitscripts_temp_bash_profile_path}"


echo "	> sending scripts to etc..."
cp "${flgitscripts_temp_bash_profile_path}" "${native_bash_profile_path}"

echo "	> cleaning up temporary files..."
rm $tmp
#rm "${flgitscriptss_temp_bash_profile_path}"


echo "	> sourcing: ${native_bash_profile_path}"
source "${native_bash_profile_path}"

echo
echo ${STYLE_BRIGHT}"Your bash profile has been refreshed!"${X}
echo
echo
