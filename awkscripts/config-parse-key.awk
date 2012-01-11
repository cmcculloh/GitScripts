BEGIN {
	if (length(key) > 0) {
		keyEq = key "="
		patt = "^" keyEq
	} else {
		print "incoming key not found!"
		#exit 1
	}
}
$0 ~ patt {
	gsub(keyEq, "")
	print
}