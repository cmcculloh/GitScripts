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
export flscripts_path="${SCRIPT_PATH}/"
popd  > /dev/null


echo "Preparing to refresh your bash profile..."

touch "${flscripts_path}bash_profile_config.overrides"
touch "${flscripts_path}environment_config.overrides"

source "${flscripts_path}environment_config.overrides"
source "${flscripts_path}environment_config.default"

touch "${flscripts_temp_bash_profile_path}"

echo "	> concatenating scripts..."
cat "${flscripts_path}environment_config.overrides" "${flscripts_path}line_break" "${flscripts_path}environment_config.default" "${flscripts_path}line_break" "${flscripts_path}bash_profile_config.overrides" "${flscripts_path}line_break" "${flscripts_path}bash_profile_config" > "${flscripts_temp_bash_profile_path}"


echo "	> sending scripts to etc..."
cp "${flscripts_temp_bash_profile_path}" "${native_bash_profile_path}"
#rm "${flscripts_temp_bash_profile_path}"

${STYLE_NORM}

echo "	> sourcing: ${native_bash_profile_path}"
source "${native_bash_profile_path}"

echo
echo ${TEXT_BRIGHT}"Your bash profile has been refreshed!"${X}
echo
echo
