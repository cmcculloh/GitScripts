source "${gitscripts_path}environment_template"

cat "${gitscripts_path}environment_template" "${gitscripts_path}bash_profile_template" > "${gitscripts_path}bash_profile"

cp "${gitscripts_path}bash_profile" "${git_install}bash_profile"
cp "${gitscripts_path}motd" "${git_install}motd"

rm "${gitscripts_path}bash_profile"

source "${git_install}bash_profile"
