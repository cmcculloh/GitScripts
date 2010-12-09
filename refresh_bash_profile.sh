source environment_template

cat environment_template bash_profile_template > bash_profile

cp "${gitscripts_path}bash_profile" "${git_install}bash_profile"
cp "${gitscripts_path}motd" "${git_install}motd"

rm bash_profile

source "${git_install}bash_profile"
