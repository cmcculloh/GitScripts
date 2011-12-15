# the {n,m} pattern repitation syntax doesn't work in this version of awk...
/^[A-Za-z][A-Za-z][A-Za-z][0-9][0-9][0-9][0-9][0-9]/ {
	ticketNum = substr($0,1,8)
	theRest = substr($0,9)

	# match() will return the position of the first letter or number it encounters
	# signifying the start of the ticket subject line.
	descStart = match(theRest,/[a-zA-Z0-9]/)
	desc = substr(theRest,descStart)

	# 1) eliminate quotes completely.
	# 2) replace other special characters with a hyphen.
	# 3) kill off trailing hyphens
	gsub(/["']/,"",desc)
	gsub(/[.,;:[:blank:]/\\]+/,"-",desc)
	gsub(/-+$/,"",desc)

	print toupper(ticketNum) "---" tolower(desc)
}