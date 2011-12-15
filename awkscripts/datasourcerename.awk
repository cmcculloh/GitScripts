BEGIN {
	envpatt = "-" env "-"
	bupatt = "." ext
}
$0 ~ dsprefix {
	if ($0 ~ envpatt) {
		extpos = index($0,bupatt)
		if (extpos > 0) {
			print substr($0,1,extpos - 1)
		} else {
			print
		}
	} else if ($0 !~ bupatt) {
		print $0 bupatt
	} else {
		print
	}
}