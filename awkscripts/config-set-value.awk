BEGIN {
	if (length(key) == 0 || length(value) == 0) {
		exit 1
	} else {
		keyEq = key "="
	}
}
{
	if (index($0,keyEq) == 1) {
		print keyEq value
	} else {
		print
	}
}