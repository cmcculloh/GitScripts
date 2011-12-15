echo "preparing to refresh your bash profile"

touch "${gitscripts_path}bash_profile_config.overrides"
touch "${gitscripts_path}environment_config.overrides"

source "${gitscripts_path}environment_config.overrides"
source "${gitscripts_path}environment_config.default"
#source "${gitscripts_path}environment_config.overrides"


cat "${gitscripts_path}environment_config.overrides" "${gitscripts_path}line_break" "${gitscripts_path}environment_config.default" "${gitscripts_path}line_break" "${gitscripts_path}environment_config.overrides" "${gitscripts_path}line_break" "${gitscripts_path}bash_profile_config.overrides" "${gitscripts_path}line_break" "${gitscripts_path}bash_profile_config" > "${gitscripts_temp_bash_profile_path}"


#touch "${native_gitscripts_bash_profile_path}"
#touch "${native_gitscripts_bash_motd_path}"

cp "${gitscripts_temp_bash_profile_path}" "${native_bash_profile_path}"
#cp "${gitscripts_path}motd" "${native_gitscripts_bash_motd_path}"

rm "${gitscripts_temp_bash_profile_path}"

echo "Going to source: ${native_bash_profile_path}"

source ${gitscripts_path}set-bash-colors.sh
source ${gitscripts_path}bashmarks.sh


source "${native_bash_profile_path}"


#source "${native_gitscripts_bash_profile_path}"

## ADDED BY SMOLA ##

	#prevent Heap error
export ANT_OPTS="-Xms64m -Xmx512m -Duser.language=en -XX:PermSize=128M -XX:MaxPermSize=256M "

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

echo ""
echo "Refreshed your bash profile."
echo ""
echo ""

