## /*
#	@usage __menu <list> [prompt]
#
#	@vars
#	$_menu_selection
#	vars@
#
#	@description
#	Takes a white-space separated list and outputs each element as a selectable item
#	in a menu. The message for selecting a menu item can be passed as the second paramter.
#	description@
#
#	@notes
#	- If 'list' has been stored in a variable, be sure to enclose the variable name in
#	double quotes!
#	notes@
#
#	@examples
#		list="bolah lah blah"
#		msg="this is a message"
#		__menu "$list" "$msg"
#		__menu "$list"
#
#		echo "You selected: ${_menu_selection}"
#	examples@
## */

__menu() {
	if [ -z "$1" ]; then
		__gslog "__menu: First parameter must be white-space separated list. Nothing given."
		return 1
	fi

	# build menu
	local items=( $1 )
	echo ${STYLE_MENU_HL}${H2HL}${X}
	for (( i = 1 ; i <= ${#items[@]} ; i++ ))
		do
		j=$(( i - 1 ))
		item="${items[$j]}"

		if (( i < 10 )); then
			index="  "$i
		elif (( i < 100 )); then
			index=" "$i
		else
			index=$i
		fi
		echo "${STYLE_MENU_INDEX}${index}:${X} ${STYLE_MENU_OPTION}${item}${X}"
	done
	echo ${STYLE_MENU_HL}${H2HL}${X}

	# check for custom message
	msg=$2
	if [ -z "$2" ]; then
		msg="Please make a selection (or press Enter to abort): "
	fi
	echo ${STYLE_MENU_PROMPT}"$msg"${X}
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
	echo ${O}"You chose:${X} ${_menu_selection}"
	export _menu_selection

	return 0
}
