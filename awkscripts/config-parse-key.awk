BEGIN {
	if (length(key) > 0) {
		keyEq = key "="
		patt = "^" keyEq
	} else {
		print "incoming key not found!"
		#exit 1
	}
}

# for lines that begin with the given key followed by =, delete
# key and = leaving only the value, then print it.
$0 ~ patt {
	sub(keyEq, "")
	print
}