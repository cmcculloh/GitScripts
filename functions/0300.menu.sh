## /* @function
#	@usage __menu <arr> ["$message"]
#	@description
#	Takes an array and outputs each element as a selectable item
#	description@
#
#	@examples
#		arr="bolah lah blah"
#		msg="this is a message"
#		__menu arr "$msg"
#		__menu arr
#
#		echo "exported $_menu_selection"
#	examples@
#
#	@vars _menu_selection
## */
__menu() {
	local items=$1[@]
	items=(${!items})
	for (( i = 0 ; i < ${#items[@]} ; i++ ))
		do
		item=$(echo ${items[$i]})

		if [ $i -le "9" ] ; then
			index="  "$i
		elif [ $i -le "99" ] ; then
			index=" "$i
		else
			index=$i
		fi
		echo "$index: $item"
	done

	msg=$2
	if [ -z "$2" ]
		then
		msg="Please make a selection: "
	fi
	echo $msg
	read selection

	_menu_selection=${items[$selection]}

	echo "You chose: $_menu_selection"

	export _menu_selection
}
