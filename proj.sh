#!/bin/bash
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
				echo "  Adding: ${B}\`$1\`${X}"
				if ! grep -q "$1" "$proj_file"; then
					echo "$1" >> "$proj_file"
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
		if ! grep -q "$2${ext}" <<< "`ls ${inputdir}`"; then
			touch "${inputdir}$2${ext}"
			__flgs_config set "proj.which" "$2"
			echo
			echo "  Project ${COL_MAGENTA}$2${X} created!"
		else
			echo
			echo ${E}"  Project \`$2\` already exists!  "
			exit 1
		fi
		;;


	"open")
		inputs=( `ls "$inputdir"` )
		declare -a projects
		for (( i = 0; i < ${#inputs[@]}; i++ )); do
			if grep -q $ext <<< "${inputs[i]}"; then
				projects[${#projects[@]}]="${inputs[i]/$ext}"
			fi
		done
		if (( ${#projects[@]} > 0 )); then
			__menu --prompt="Choose a project to open" ${projects[@]}
			if [ -n "$_menu_sel_value" ]; then
				__flgs_config set "proj.which" "$_menu_sel_value"
				echo
				echo "  Project ${COL_MAGENTA}${_menu_sel_value}${X} opened.  "
			fi
		fi
		;;


	"subtract")
		which=`"${flgitscripts_path}"proj.sh which`
		proj_file="${inputdir}${which}${ext}"
		if [ -n "$which" ]; then
			items=( `cat "$proj_file"` )
			tempfile="${tmp}proj"
			__menu --prompt="Choose an item to subtract from project list" ${items[@]}
			if [ -n "$_menu_sel_value" ]; then
				while read line; do
					if ! grep -q "$_menu_sel_value" <<< "$line"; then
						echo "$line" >> "$tempfile"
					fi
				done <"$proj_file"
				mv -f "$tempfile" "$proj_file"
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
