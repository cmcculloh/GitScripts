## /*
#	@usage flvarsreset
#
#	@description
#	Massive resets for when major changes occur to the working tree or variables.
#	The main uses are for development, but this reset is also useful if overriding
#	certain variables in *.overrides files.
#	description@
#
#	@notes
#	- Although given the option, it is STRONGLY recommended to run the
#	  refresh_bash_profile command after resetting script variables.
#	notes@
## */

echo ${X}
echo "${A}Resetting${X} variables..."
echo

# these must come before ANT declarations
export GIT_INSTALL=
export GIT_BIN=
export GIT_ETC=

# must remain in this order
export JBOSS_HOME=
export JBOSS_LOGS=
export JBOSS_DEPLOY=
export JBOSS_WEBAPPWAR=
export JBOSS_MEDIAWAR=

# must remain in this order
export JAVA_DEV_HOME=
export JDK_VERSION=
export JAVA_HOME=
export ANT_HOME=
export ANT_CONTRIB_HOME=
export YUI_COMPRESSOR_HOME=
export ANT_ANT_LIB=
export ANT_OPTS=
export ANT_ARGS=


export awkdir=
export awkscripts_path=
export buildsprojectname=
export builds_path=
export development_root=
export finishline_path=
export flgitscripts_config=
export flgitscripts_config_defaults=
export flgitscripts_config_path=
export flgitscripts_path=
export flgitscripts_temp_bash_profile_path=
export flgitscriptsprojectname=
export gitscripts_motd_path=
export gitscripts_path=
export inputdir=
export mainprojectname=
export mediaActuallyUseful_path=
export mediaLandingPagesPath=
export mediaprojectname=
export merginator_finishline_path=
export merginator_path=
export myenvironment=
export native_bash_profile_path=
export native_motd_path=
export outputdir=
export project_workspace=
export promos_path=
export tempdir=
export tmp=
export webappwar_path=
export workspace_name=
export workspace_path=



echo "FL Variables reset! ${Q}Would you like to run ${A}refresh_bash_profile${Q}? (y) n"
read yn

if [ -z "$yn" ] || [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
	echo
	source "${flgitscripts_path}refresh_bash_profile.sh"

	echo "bash profile refreshed! ${Q}Would you like to run ${A}varsreset${Q}? (y) n"
	read yn

	if [ -z "$yn" ] || [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
		echo
		source "${gitscripts_path}varsreset.sh"
	fi
	
fi

