function cleanup(STR,  strt) {
	strt = match(STR,/"([^"]+\.jspf?[^"]*)/)
	if (strt > 0) {
		file = substr(STR,RSTART + 1, RLENGTH - 1)
		print NR ": " file
	}
	return
}

/include file=/ {
	cleanup($0)
}
/include page=/ {
	cleanup($0)
}
/name="pageLink"/ {
	cleanup($0)
}
/name="bodyContentTemplate"/ {
	cleanup($0)
}
/href="/ {
	cleanup($0)
}