BEGIN {
	# all tokens/tags should be placed here for easy modification
	gsmStart = "^[[:blank:]]*##[[:blank:]]*\\/\\*[[:blank:]]*$"
	gsmStop = "^[[:blank:]]*##[[:blank:]]*\\*\\/[[:blank:]]*$"
	tagStart = "[[:blank:]]@[[:alnum:]]+[[:blank:]]?"
	tagStop = "[[:blank:]][[:alnum:]]+@[[:blank:]]?"

	tagColor = "\033[36m"	#cyan
	tagX = "\033[0;20;39m"	#reset styles
}

# the opening tag: ## /*
$0 ~ gsmStart {
	do {
		getline ln
		mtch = match(ln, gsmStop)
		if (mtch == 0) {
			data = substr(ln, 2)

			#color tags
			openTag = match(data, tagStart)
			if (openTag > 0) {
				tagText = substr(data, RSTART, RLENGTH)
				newText = tagColor " " tagText " " tagX		#include spaces so next gsub doesnt yield unexpected results
				gsub(tagText, newText, data)
			}

			#closing tags don't actually need to be displayed
			closeTag = match(data, tagStop)
			if (closeTag > 0) {
				tagText = substr(data, RSTART, RLENGTH)
				gsub(tagText, "", data)
			}

			print data
		}
	} while( mtch == 0 )
}
