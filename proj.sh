#!/bin/bash
## /*
#	@usage proj add branch-name [branch-name2 [...]]
#	@usage proj delete [project-name]
#	@usage proj merge [--squash]
#	@usage proj new proj-name
#	@usage proj open [project-name]
#	@usage proj rm [branch-name]
#	@usage proj view
#	@usage proj which
#
#	@description
#	This script is meant to be used as a mini-merginator. Originally designed for promos,
#	it retains a list of branches and then merges them together on command. Essentially
#	a "proj" is a wrapping branch. It comes with the following commands:
#
#	add......| Add a branch name to the project. You can add multiple branches at once. If
#	.........| the keyword "this" is used, the branch the current repo points to will be added
#	.........| to the currently opened project.
#	delete...| Delete a project. If no project is specified, a menu allows you to choose
#	.........| from a list of all your projects.
#	merge....| Delete the branch with the same name as your open project if it exists. Create
#	.........| a branch with the same name as your open project, and then merge all of the
#	.........| branches listed in the project. If the --squash option is specified, a commit
#	.........| will not occur until all of the branches have been merged together. This
#	.........| makes the history appear as if all work in all branches was done in one commit.
#	new......| Create a new project and open it.
#	open.....| Open an existing project. If no project-name is specified, a menu will appear
#	.........| allowing you to choose from a list of all your projects.
#	rm.......| Remove a branch-name from the currently open project. If no branch-name is
#	.........| specified, a menu will appear allowing you to choose from all branches included
#	.........| in the project.
#	view.....| View a list of all branch names in the currently open project.
#	which....| View the name of the currently open project.
#	description@
#
#	@notes
#	- All commands which *could* have tab completion, DO have tabbed completion. For example,
#	if you have typed "proj open ", pressing tab twice will pop a list of all defined projects.
#	- Spaces are not allowed in project names. They are automatically converted to hyphens.
#	notes@
#
#	@examples
#	1) proj add one-branch-name a-sister-branch
#	2) proj new my brand new project
#	# creates the project "my-brand-new-project"
#	examples@
#
#	@dependencies
#	cfg/flgs.config
#	functions/1200.flgs_config.sh
#	gitscripts/functions/0100.bad_usage.sh
#	gitscripts/functions/1000.set_remote.sh
#	gitscripts/functions/5000.branch_exists.sh
#	gitscripts/functions/5000.branch_exists_remote.sh
#	dependencies@
#
#	@file proj.sh
## */
$loadfuncs
$flloadfuncs

ext=".proj"

case "$1" in
	"add")
		[ -z "$2" ] && __bad_usage proj "No data given to add." && exit 1
		which=`"${flgitscripts_path}"proj.sh which`
		if [ -n "$which" ]; then
			proj_file="${inputdir}${which}${ext}"
			echo
			shift
			while [ -n "$1" ]; do
				br=`sed 's/ /-/g' <<< "$1"`
				[ "$br" = "this" ] && br="$(__parse_git_branch)"
				echo "  Adding: ${B}\`${br}\`${X}"
				if ! grep -q "$br" "$proj_file"; then
					echo "$br" >> "$proj_file"
				else
					echo ${E}"  Data already exists in project.  "${X}
				fi
				shift
			done
		else
			echo
			echo ${E}"  No opened project. You must open a project before you can add to it.  "${X}
			exit 1
		fi
		;;


	"delete")
		declare -a projects
		projects=( `ls ${inputdir} | grep '.proj' | sed 's/\.proj$//'` )

		if (( ${#projects[@]} > 0 )); then
			if [ -n "$2" ]; then
				if grep -q "$2${ext}" <<< "`ls $inputdir`"; then
					project="$2"
				else
					echo
					echo ${E}"  Project '$2' not found!  "${X}
					exit 1
				fi
			else
				__menu --prompt="Choose a project to remove" ${projects[@]}
				if [ -n "$_menu_sel_value" ]; then
					project="$_menu_sel_value"
				fi
			fi

			if [ -n "$project" ]; then
				[ "`"${flgitscripts_path}"proj.sh which`" = "$project" ] && __flgs_config set "proj.which" ""
				rm -f "${inputdir}${project}${ext}"
				echo
				echo "  Project ${COL_MAGENTA}${project}${X} removed.  "
			fi
		fi
		;;


	"merge")
		__set_remote
		which=`"${flgitscripts_path}"proj.sh which`
		if [ -n "$which" ]; then
			# project branch must exist before merging into it
			if __branch_exists "$which"; then
				if [ "`__parse_git_branch`" = "$which" ]; then
					git checkout master
				fi

				# remove remote branch
				if __branch_exists_remote "$which"; then
					git push $_remote :"$which"
				fi

				#remove local branch
				git branch -D "$which"
			fi

			start=$([ -n "$_remote" ] && echo "$_remote/master" || echo "master")

			echo
			echo
			echo "Creating project branch..."
			echo ${O}${H2HL}
			echo "$ git checkout -b $which $start"
			git checkout -b "$which" "$start"
			isOK=$?
			echo ${O}${H2HL}${X}

			#set up tracking for when the branch later gets pushed
			if [ -n "$remote" ]; then
				git config branch.$which.remote $_remote
				git config branch.$which.merge refs/heads/$which
			fi

			# do the merge. check for squash option
			[ "$2" = "--squash" ] && squash="--squash"
			(( isOK == 0 )) && { while read line; do
				lines="$lines\n$line"
				echo
				echo
				echo "Merging: $line"
				echo ${O}${H2HL}
				echo "$ git merge $squash $line"
				git merge $squash "$line"
				result=$?
				echo ${O}${H2HL}${X}

				if (( result != 0 )); then
					echo
					echo ${E}"  Merge failed. Perhaps there was a conflict. Please resolve and try again.  "
					exit
				fi
			done <"${inputdir}${which}${ext}"; }

			# make squashed commit
			if [ $squash ]; then
				echo
				echo
				echo ${A}Committing${X} squashed branches...
				echo ${O}${H2HL}
				echo -e "$ git commit -m \"(${which}) Included branches:${lines}\""
				git commit -m "`echo -e "(${which}) Included branches:${lines}"`"
				echo ${O}${H2HL}${X}
			fi

			echo
			echo
			echo ${Q}"Would you like to ${A}push${X} your project? (y) n"
			read yn
			if [ -z "$yn" ] || [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
				"${gitscripts_path}"push.sh "$which"
			fi
		else
			echo
			echo ${E}"  You must open a project before merging.  "${X}
		fi
		;;


	"new")
		[ -z "$2" ] && __bad_usage proj "No name given for new project." && exit 1
		shift
		projname=`sed 's/ /-/g' <<< "$@"`
		if ! grep -q "${projname}${ext}" <<< "`ls ${inputdir}`"; then
			touch "${inputdir}${projname}${ext}"
			__flgs_config set "proj.which" "${projname}"
			echo
			echo "  Project ${COL_MAGENTA}${projname}${X} created!"
		else
			echo
			echo ${E}"  Project \`${projname}\` already exists!  "
			exit 1
		fi
		;;


	"open")
		declare -a projects
		projects=( `ls ${inputdir} | grep '.proj' | sed 's/\.proj$//'` )

		if (( ${#projects[@]} > 0 )); then
			if [ -n "$2" ]; then
				if grep -q "$2${ext}" <<< "`ls $inputdir`"; then
					__flgs_config set "proj.which" "$2"
					echo
					echo "  Project ${COL_MAGENTA}$2${X} opened.  "
				else
					echo
					echo ${E}"  Project '$2' not found!  "${X}
					exit 1
				fi
			else
				__menu --prompt="Choose a project to open" ${projects[@]}
				if [ -n "$_menu_sel_value" ]; then
					__flgs_config set "proj.which" "$_menu_sel_value"
					echo
					echo "  Project ${COL_MAGENTA}${_menu_sel_value}${X} opened.  "
				fi
			fi
		fi
		;;


	"rm")
		which=`"${flgitscripts_path}"proj.sh which`
		proj_file="${inputdir}${which}${ext}"
		if [ -n "$which" ]; then
			items=( `cat "$proj_file"` )
			tempfile="${tmp}proj"
			if [ -n "$2" ]; then
				if grep -q "$2" <<< "${items[@]}"; then
					item="$2"
				else
					echo
					echo ${E}"  Branch \`$2\` not found in project!  "${X}
					exit 1
				fi
			else
				__menu --prompt="Choose an item to subtract from project list" ${items[@]}
				if [ -n "$_menu_sel_value" ]; then
					item="$_menu_sel_value"
				fi
			fi
			if [ -n "$item" ]; then
				while read line; do
					if ! grep -q "$item" <<< "$line"; then
						echo "$line" >> "$tempfile"
					fi
				done <"$proj_file"
				mv -f "$tempfile" "$proj_file"
				echo
				echo "Branch ${B}\`${item}\`${X} removed from project!"
			fi
		fi
		;;


	"view")
		which=`"${flgitscripts_path}"proj.sh which`
		proj_file="${inputdir}${which}${ext}"
		if [ -f "$proj_file" ]; then
			cat "$proj_file"
		fi
		;;


	"which")
		if __flgs_config_search "proj.which"; then
			__flgs_config get "proj.which"
		# else
		# 	echo "No opened project found."
		fi
		;;
esac

exit
