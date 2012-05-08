BEGIN {
	# all tokens/tags should be placed here for easy modification
	gsmStart = "^[[:blank:]]*##[[:blank:]]*\\/\\*"
	gsmStop = "^[[:blank:]]*##[[:blank:]]*\\*\\/"

	tagStart = "(^|[[:blank:]]*)@[[:alnum:]]+"
	tagStop = "(^|[[:blank:]]*)[[:alnum:]]+@"

	tagColor = "\033[36m"	#cyan
	tagX = "\033[0;20;39m"	#reset styles
}

# the opening tag: ## /*
$0 ~ gsmStart {
	# print any descriptors for the comment
	dMatch = match($0, /@[[:alnum:]]+/)
	print "type:" substr($0, RSTART + 1, RLENGTH - 1)

	i = 2
	do {
		# process the rest of the lines
		getline ln

		# usage string
		if (i == 2) {
			if (match(ln, /@usage/) > 0) {
				usageString = substr(ln, RSTART + RLENGTH + 1)
				split(usageString, usagePieces, / /)
				print "name:" usagePieces[1]
			} else {
				print "name:"
			}
		}

		mtch = match(ln, gsmStop)
		if (mtch == 0) {
			data = tagX substr(ln, 2)

			# color open tags
			if (match(data, tagStart) > 0) {
				tagText = substr(data, RSTART, RLENGTH)
				newText = tagColor " " tagText " " tagX		#include spaces so next gsub doesnt yield unexpected results
				gsub(tagText, newText, data)
			}

			#closing tags don't actually need to be displayed
			if (match(data, tagStop) > 0) {
				tagText = substr(data, RSTART, RLENGTH)
				gsub(tagText, "", data)
			}

			print tagX data
		}

		i++
	} while( mtch == 0 )
}
