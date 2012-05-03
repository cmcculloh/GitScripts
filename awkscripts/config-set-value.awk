BEGIN {
	if (length(key) == 0) {
		exit 1
	} else {
		keyEq = key "="
	}
}

# for EVERY line, either set value for key or simply print what already exists
{
	if (index($0,keyEq) == 1) {
		print keyEq value
	} else {
		print
	}
}