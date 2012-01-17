BEGIN {
	if (ndxLen !~ /[[:digit:]]+/) {
		ndxLen = 3
	}
}
{
	# expected input is of the format :index:value
	if (match($0, /^:[[:alnum:]]+:/) == 1) {
		ndx = substr($0, 2, RLENGTH - 2)
		msg = substr($0, RLENGTH + 1)

		# remove unwanted spaces, if any
		gsub(/[[:blank]]+/, "", ndx)
		sub(/^[[:blank]]+/, "", msg)

		# output only separated by spaces. to be parsed in calling script
		print ndx " " msg
	}
}