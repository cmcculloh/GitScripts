{
	arrSize = split($0,dirs,"/")

	# if path specified with trailing slash, last element will be empty
	# in either case, delete the last folder as syntax for cp requires it for a successful update
	if (dirs[arrSize] == "") {
		delete dirs[arrSize]
		delete dirs[arrSize - 1]
		arrSize = arrSize - 2
	} else {
		delete dirs[arrSize]
		arrSize = arrSize - 1
	}

	newPath = ""
	for (i = 1; i <= arrSize; i++) {
		if (dirs[i] != "") newPath = newPath "/" dirs[i]
	}
	print newPath
}