## /* @function
#	@usage __menu
#
#	@output true
#
#	@description
#	Takes an array and outputs each element as a selectable item
## */
__menu() {
	local items=$1[@]
	items=(${!items})
	for (( i = 0 ; i < ${#items[@]} ; i++ ))
		do
		#TODO: make it so that you can pass through a sed value (or two or three) to be run on each item
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
}

arr=(bolah lah blah)
__menu arr
