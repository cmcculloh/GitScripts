BEGIN {
	uri = ""
	l1 = ""
	l2 = ""
	l3 = ""
	printed = 1
}
/^[:]/ {
	getline
	getline uri
	gsub(/[[:blank:]]/,"",uri)
	if (printed == 1) {
		print ""
		print "	Dir >>> >>> " uri
		printed = 0
	}
}
{
	l3 = l2
	l2 = l1
	l1 = $0

	if (l3 ~ /[a-z]/ && index(l1,l3) > 0 && index(l2,l3) > 0) {
		print l3
		printed = 1
	}
}