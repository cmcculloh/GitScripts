## /* @function
#	@usage __menu [options] <list> [extra-list]
#
#	@output true
#
#	@vars
#	$_menu_sel_index
#	$_menu_sel_value
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
#	functions/0400.in_array.sh
#	dependencies@
#
#	@file functions/0300.menu.sh
## */

__menu() {
	declare -a extraItems
	local i
	local index
	local item
	declare -a items
	local j
	local opt
	local pair
	local prompt

	numArgs=$#
	if (( numArgs > 0 && numArgs < 4 )); then
		until [ -z "$1" ]; do
			echo "$1" | egrep -q "^--prompt=" && prompt=$( echo "$1" | awk '{ print substr($0,10); }' )
			echo "$1" | egrep -q "^:" && extraItems[${#extraItems[@]}]="$1"
			! echo "$1" | egrep -q "^(--prompt|:)" && items[${#items[@]}]="$1"
			shift
		done
	fi

	if [ ${#items[@]} -eq 0 ] && [ ${#extraItems[@]} -eq 0 ]; then
		__gslog "__menu: No lists given. Given: $@"
		echo ${E}"  __menu did not detect any list items to display. Aborting...  "${X}
		return 1
	fi

	# reset output variables
	export _menu_sel_index=
	export _menu_sel_value=

	# check for custom message
	local msg="Please make a selection (or press Enter to abort)"
	if [ -n "$prompt" ]; then
		msg="$prompt"
	fi

	# build menu
	echo ${STYLE_MENU_HL}${H2HL}${X}
	echo ${STYLE_MENU_HEADER}"  $msg  "${X}
	echo ${STYLE_MENU_HL}${H2HL}${X}

	if [ ${#items[@]} -gt 0 ]; then
		for (( i = 1 ; i <= ${#items[@]} ; i++ )); do
			j=$(( i - 1 ))
			item="${items[$j]}"

			# make indexes right-aligned. works for up to 999 choices.
			if (( i < 10 )); then
				index="  $i"
			elif (( i < 100 )); then
				index=" $i"
			else
				index="$i"
			fi
			echo "  ${STYLE_MENU_INDEX}${index}:${X}  ${STYLE_MENU_OPTION}${item}${X}"
		done
		echo ${STYLE_MENU_HL}${H2HL}${X}
	fi

	# If extra list is given, parse
	if [ ${#extraItems[@]} -gt 0 ]; then
		declare -a parsedItems
		declare -a ndxes
		declare -a vals
		i=0
		for pair in ${extraItems[@]}; do
			parsedItems[$i]=$(echo "$pair" | awk -f "${gitscripts_awk_path}menu_extra_option_parse.awk")
			# echo "${extraItems[$i]}"
			ndxes[$i]=$(echo "${parsedItems[$i]}" | cut -f 1 -d" ")
			vals[$i]=$(echo "${parsedItems[$i]}" | cut -f 2- -d" ")

			# printf was not working when providing the field width specifier. Scripts that call this
			# function are most likely getting called as subprocesses, which have some leading/trailing
			# whitespace removed when output to the parent script. The fix below seems to work, however.
			echo -n ${STYLE_MENU_INDEX}
			echo | awk -v ndx="${ndxes[$i]}" '{ printf("  %3s:",ndx); }'
			echo ${STYLE_MENU_OPTION}"  ${vals[$i]}"${X}
			(( i++ ))
		done
		echo ${STYLE_MENU_HL}${H2HL}${X}
	fi

	echo -n ${STYLE_MENU_PROMPT}"  $msg:  "${X}
	read opt

	# validate response
	if [ -n "$opt" ]; then
		_menu_sel_index="$opt"
		if [ ${#extraItems[@]} -gt 0 ] && __in_array "$opt" "${ndxes[@]}"; then
			_menu_sel_value="${vals[${_in_array_index}]}"

		elif echo "$opt" | egrep -q '^[[:digit:]]+$'; then
			local optndx
			(( optndx = opt - 1 ))
			if [ -n "${items[$optndx]}" ]; then
				_menu_sel_value="${items[$optndx]}"
			fi

		else
			echo
			echo ${E}"  Invalid selection! Aborting...  "${X}
			return 1
		fi
	fi

	#wrap up...
	echo
	echo ${X}"  You chose: ${_menu_sel_index}"
	export _menu_sel_index
	export _menu_sel_value

	return 0
}
