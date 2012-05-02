# this pattern looks for Git installs on a windows machine
/^[A-Za-z]:\\.*on \/ / {
	endofpath = match($0,/ on \/ /);
	if (endofpath > 0) {
		drive = tolower(substr($0, 1, 1))
		path = substr($0, 4, endofpath - 4)
		gsub(/\\/,"/",path)
		print "/" drive "/" path
	}
}