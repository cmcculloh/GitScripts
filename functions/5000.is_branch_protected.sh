## /* @function
#	@usage __is_branch_protected <keyword> <branch-name>
#
#	@output false
#
#	@description
#	Making basic checks for protected branches is an integral part of keeping
#	team projects as safe as possible. It's also helpful just to protect you
#	from yourself sometimes. This function provides those checks.
#	description@
#
#	@options
#	--all			Checks to see if branch is protected ANYWHERE.
#	--merge-from	Checks for protected branches that merge into other branches.
#	--merge-to		Checks for protected branches that shouldn't be merged into.
#	--push			Checks for protected branches that cannot be pushed to.
#	options@
#
#	@notes
#	- This function returns SUCCESS on error as the safest option is to
#	protect the branch if something goes wrong. FAILURE is returned if
#	the branch is not protected.
#	- Paths with spaces will cause a SUCCESS.
#	- Echoing an error is preferred to logging it with __gslog to better debug
#	script errors.
#	notes@
#
#	@examples
#	if __is_branch_protected --push master; then
#		echo "Sorry, you can't push to master."
#	else
#		eval "${gitscripts_path}push.sh master"
#	fi
#	examples@
#
#	@file functions/5000.is_branch_protected.sh
## */

function __is_branch_protected {
	if [ $# -ne 2 ]; then
		echo ${E}"  __is_branch_protected: Must have 2 parameters (keyword and branch-name).  "${X}
		return 0
	fi

	case "$1" in
		"--all")
			local checkPath="$protectpushto_path $protectmergeto_path $protectmergefrom_path";;

		"--push")
			local checkPath="$protectpushto_path";;

		"--merge")
			local checkPath="$protectmergeto_path $protectmergefrom_path";;

		"--merge-to")
			local checkPath="$protectmergeto_path";;

		"--merge-from")
			local checkPath="$protectmergefrom_path";;

		*)
			echo ${E}"  __is_branch_protected: First parameter ($1) not recognized.  "${X}
			return 0;;
	esac

	# since multiple paths can be given, we should loops through them
	for path in $checkPath; do
		[ -s "$path" ] && cat $path | grep -q "$2" && local protected=true
	done

	if [ $protected ]; then
		return 0
	else
		return 1
	fi
}
