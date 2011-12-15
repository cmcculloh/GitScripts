{
	#change to lowercase for searching
	look = index(tolower($0),tolower(name))

	if (look != 0) print $0
}