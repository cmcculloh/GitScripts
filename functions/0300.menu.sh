## /* @function
#	@usage __menu [--prompt=msg] [ [list-item] [list-item] ... ] &| [-k [list-item] [list-item] ...]
#
#	@output true
#
#	@vars
#	$_menu_sel_index
#	$_menu_sel_value
#	vars@
#
#	@description
#	Each parameter is considered a list item in the order in which they are passed.
#	The script stores each parameter and outputs each element as a selectable item
#	in a menu. By default, a numeric-based list is generated for each list-item.
#	If you require a second list that has user-specified indexes (non-numeric), you
#	can pass them using the following format (note the -k option):
#
#		__menu -k ":key1:list item description" ":key2:list item description ..."
#
#	Each index must be contained within colons. The leading colon is used when parsing
#	parameters, and to ensure the desired index is what will appear in the menu. If this
#	leading colon isn't provided, the extra-list may get interpreted as the menu prompt!
#
#	The message for selecting a menu item can be passed as a parameter as well using
#	the syntax described below.
#	description@
#
#	@options
#	--prompt=msg	Change the default promp to msg. Be sure to enclose msg in double quotes.
#	-k          	Begin the list of key-defined list items. These must come AFTER any
#	            	numeric-based list items, if included.
#	options@
#
#	@notes
#	- If you wish to pass an array as a parameter, be sure to enclose the variable name
#	in double quotes! Otherwise, the contents will not get expanded!
#	- User-specified indexes using the colon-based format are displayed below any numeric-
#	based list.
#	- Formatting allows for all keys to be at most 3 characters long.
#	- For custom prompts, do NOT include a trailing colon. It is added automatically.
#	notes@
#
#	@examples
#	list="oolah boolah boo"
#	msg="this is a message"
#	__menu --prompt="$msg" $list
#
#	# output of __menu command (snippet) above would be
#	# ...
#	# 1.  oolah
#	# 2.  boolah
#	# 3.  boo
#	# --------------------------------------------
#	# this is a message:
#
#	echo "You selected: ${_menu_selection}"
#
#	### ...OR we could add an extra option... ###
#
#	__menu $list -k ":N:Show me something new!"
#
#	### Can be effectively used in conditional scripts as well ###
#
#	if __menu $list ":N:Show me something new!"; then
#	    case $_menu_sel_index in
#	        1)
#	            ...
#
#	        ...
#	        # don't forget your custom option!
#	        N) ...;;
#
#	        # the only other success in this case is if the user pressed enter to abort.
#	        # remember __menu will output "You chose to abort."
#	        *)
#	            echo "Exiting..."; exit 0;;
#		esac
#	else
#	    echo "Sorry, your choice was not understood. Exiting..."
#	    exit 1
#	fi
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
	local k=
	local opt
	local pair
	local prompt=

	if [ $# -gt 0 ]; then
		egrep -q "^--prompt=" <<< "$1" && { prompt=$( awk '{ print substr($0,10); }' <<< "$1"); shift; }
		egrep -q ' -k :' <<< "$@" && k=true

		if [ $k ]; then
			until [ "$1" = "-k" ]; do
				items[${#items[@]}]="$1"
				shift 1
			done
			shift 1
			until [ -z "$1" ]; do
				extraItems[${#extraItems[@]}]="$1"
				shift 1
			done
		else
			until [ -z "$1" ]; do
				items[${#items[@]}]="$1"
				shift 1
			done
		fi
	fi

	if [ ${#items[@]} -eq 0 ] && [ ${#extraItems[@]} -eq 0 ]; then
		__gslog "__menu: No lists given. Given: $@"
		echo
		echo ${E}"  __menu did not detect any list items to display. Aborting...  "${X}
		return 1
	fi

	# reset output variables
	_menu_sel_index=
	_menu_sel_value=

	# check for custom message
	local msg="Please make a selection"
	if [ -n "$prompt" ]; then
		msg="$prompt"
	fi

	# build menu
	echo ${STYLE_MENU_HL}${H2HL}${X}
	echo ${STYLE_MENU_HEADER}"  $msg (or press Enter to abort):  "${X}
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
		local parsedItem
		declare -a ndxes
		declare -a vals
		i=0
		for pair in "${extraItems[@]}"; do
			parsedItem="${pair:1}"
			parsedItem="${parsedItem/:/ }"
			ndxes[$i]="${parsedItem%% *}"
			vals[$i]="${parsedItem#* }"

			# printf fails if colors inserted. make the output echo separately.
			echo -n ${STYLE_MENU_INDEX}; printf '  %3s:' "${ndxes[$i]}"; echo ${STYLE_MENU_OPTION}"  ${vals[$i]}"${X}
			(( i++ ))
		done
		echo ${STYLE_MENU_HL}${H2HL}${X}
	fi

	echo -n ${STYLE_MENU_PROMPT}"  $msg (or press Enter to abort):  "${X}
	read opt

	# validate response
	if [ -n "$opt" ]; then
		_menu_sel_index="$opt"
		if [ ${#extraItems[@]} -gt 0 ] && __in_array "$opt" "${ndxes[@]}"; then
			_menu_sel_value="${vals[${_in_array_index}]}"

		elif egrep -q '^[[:digit:]]+$' <<< "$opt" && [ $opt -gt 0 ]; then
			local optndx
			(( optndx = opt - 1 ))
			if [ -n "${items[$optndx]}" ]; then
				_menu_sel_value="${items[$optndx]}"
			else
				# invalid selection. no *numeric* key matches what user typed in.
				return 1
			fi

		else
			# invalid selection. no key matches what user typed in.
			return 1

		fi

		echo
		echo ${X}"  You chose: ${_menu_sel_index}"
	else
		echo
		echo ${X}"  You chose to abort.  "
	fi

	#wrap up...
	export _menu_sel_index
	export _menu_sel_value

	return 0
}
