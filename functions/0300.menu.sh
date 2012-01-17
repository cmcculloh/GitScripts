## /* @function
#	@usage __menu [options] <list> [extra-list]
#
#	@vars
#	$_menu_selection
#	vars@
#
#	@description
#	Takes a white-space separated list and outputs each element as a selectable item
#	in a menu. The message for selecting a menu item can be passed as a parameter as well.
#	If you require a second list that has user-specified indexes, you can pass it as a
#	white-space separated list with the following format:
#
#		":index1:list item description :index2:list item description ..."
#
#	Each index must be contained within colons. The leading colon is used when parsing
#	parameters, and to ensure the desired index is what will appear in the menu. If this
#	leading colon isn't provided, the extra-list may get interpreted as the menu prompt!
#	description@
#
#	@options
#	--prompt=msg	Change the default promp to msg. Be sure to enclose msg in double quotes.
#	options@
#
#	@notes
#	- If 'list' and/or 'extra-list' have been stored in a variable, be sure to enclose
#	the variable name in double quotes!
#	- For custom prompts, do NOT include a trailing colon. It is added automatically.
#	notes@
#
#	@examples
#	list="bolah lah blah"
#	msg="this is a message"
#	__menu "$list" "$msg"
#
#	echo "You selected: ${_menu_selection}"
#
#	### ...OR... ###
#
#	__menu "$list" ":N:Show me something new!"
#	examples@
#
#	@dependencies
#	functions/0200.gslog.sh
#	dependencies@
## */

__menu() {
	numArgs=$#
	if (( numArgs > 0 && numArgs < 4 )); then
		until [ -z "$1" ]; do
			echo "$1" | egrep -q "^--prompt=" && prompt=$( echo "$1" | awk '{ print substr($0,10); }' )
			echo "$1" | egrep -q "^:" && extraList="$1"
			! echo "$1" | egrep -q "^(--prompt|:)" && list="$1"
			shift
		done
	fi

	if [ -z "$list" ]; then
		__gslog "__menu: First parameter must be white-space separated list. Given: $@"
		echo ${E}"  __menu did not detect a list to display. Aborting...  "${X}
		return 1
	fi

	# reset output variable
	_menu_selection=""

	# check for custom message
	msg="Please make a selection (or press Enter to abort)"
	if [ -n "$prompt" ]; then
		msg="$prompt"
	fi

	# build menu
	local items=( $list )
	echo ${STYLE_MENU_HL}${H2HL}${X}
	echo ${STYLE_MENU_HEADER}"  $msg  "${X}
	echo ${STYLE_MENU_HL}${H2HL}${X}
	for (( i = 1 ; i <= ${#items[@]} ; i++ ))
		do
		j=$(( i - 1 ))
		item="${items[$j]}"

		# make indexes right-aligned. works for up to 999 choices.
		if (( i < 10 )); then
			index="  "$i
		elif (( i < 100 )); then
			index=" "$i
		else
			index=$i
		fi
		echo "  ${STYLE_MENU_INDEX}${index}:${X}  ${STYLE_MENU_OPTION}${item}${X}"
	done
	echo ${STYLE_MENU_HL}${H2HL}${X}

	# If extra list is given, parse
	if [ -n "$extraList" ]; then
		declare -a extraItems
		i=0
		for pair in $extraList; do
			extraItems[$i]=$(echo "$pair" | awk -f "${gitscripts_awk_path}menu_extra_option_parse.awk")
			# echo "${extraItems[$i]}"
			ndx=$(echo "${extraItems[$i]}" | cut -f 1 -d" ")
			val=$(echo "${extraItems[$i]}" | cut -f 2- -d" ")

			echo -n ${STYLE_MENU_INDEX}
			echo | awk -v ndx="$ndx" '{ printf("  %3s:",ndx); }'
			echo ${STYLE_MENU_OPTION}"  ${val}"${X}
			#echo "    ${STYLE_MENU_INDEX}${index}:${X}  ${STYLE_MENU_OPTION}${val}${X}"
			(( i++ ))
		done
		echo ${STYLE_MENU_HL}${H2HL}${X}
	fi
	return 0

	echo -n ${STYLE_MENU_PROMPT}"  $msg:  "${X}
	read selection

	# validate response
	if [ -z "$selection" ]; then
		echo
		echo ${E}"  No selection made. Aborting...  "${X}
		return 0
	else
		if echo $selection | egrep -q '^[[:digit:]]+$'; then
			(( selection-- ))
			_menu_selection=${items[$selection]}
		else
			echo
			echo ${E}"  Invalid selection! Aborting...  "${X}
			return 1
		fi
	fi

	#wrap up...
	echo
	echo ${O}"  You chose:${X} ${_menu_selection}  "
	export _menu_selection

	return 0
}
