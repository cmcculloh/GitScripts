BEGIN {
	byteCnt = 0
	fileCnt = 0
	jpgCnt = 0
	gifCnt = 0
	pngCnt = 0
	swfCnt = 0
	mp3Cnt = 0
	wavCnt = 0
	wmvCnt = 0
	txtCnt = 0
	jsCnt = 0
	cssCnt = 0
	jpgbCnt = 0
	gifbCnt = 0
	pngbCnt = 0
	swfbCnt = 0
	mp3bCnt = 0
	wavbCnt = 0
	wmvbCnt = 0
	txtbCnt = 0
	jsCbnt = 0
	cssbCnt = 0
}
/\.jpe?g$|\.gif$|\.png$|\.swf$|\.mp3$|\.wav$|\.txt$|\.wmv$|\.css$|\.js$/ {
	byteCnt += $5
	fileCnt++

	indx = split($9, bits, ".")
	ext = tolower(bits[indx])

	if (ext ~ /jpe?g/) {
		jpgCnt++
		jpgbCnt += $5
	}
	else if (ext == "gif") {
		gifCnt++
		gifbCnt += $5
	}
	else if (ext == "png") {
		pngCnt++
		pngbCnt += $5
	}
	else if (ext == "swf") {
		swfCnt++
		swfbCnt += $5
	}
	else if (ext == "mp3") {
		mp3Cnt++
		mp3bCnt += $5
	}
	else if (ext == "wav") {
		wavCnt++
		wavbCnt += $5
	}
	else if (ext == "txt") {
		txtCnt++
		txtbCnt += $5
	}
	else if (ext == "wmv") {
		wmvCnt++
		wmvbCnt += $5
	}
	else if (ext == "css") {
		cssCnt++
		cssbCnt += $5
	}
	else if (ext == "js") {
		jsCnt++
		jsbCnt += $5
	}
}
END {
	print "Counts:"
	print ""
	printf "%7s %5d  (%7.3f kb)\n", "jpeg: ", jpgCnt, jpgbCnt / 1000
	printf "%7s %5d  (%7.3f kb)\n", "gif: ", gifCnt, gifbCnt / 1000
	printf "%7s %5d  (%7.3f kb)\n", "png: ", pngCnt, pngbCnt / 1000
	printf "%7s %5d  (%7.3f kb)\n", "swf: ", swfCnt, swfbCnt / 1000
	printf "%7s %5d  (%7.3f kb)\n", "mp3: ", mp3Cnt, mp3bCnt / 1000
	printf "%7s %5d  (%7.3f kb)\n", "wav: ", wavCnt, wavbCnt / 1000
	printf "%7s %5d  (%7.3f kb)\n", "txt: ", txtCnt, txtbCnt / 1000
	printf "%7s %5d  (%7.3f kb)\n", "wmv: ", wmvCnt, wmvbCnt / 1000
	printf "%7s %5d  (%7.3f kb)\n", "css: ", cssCnt, cssbCnt / 1000
	printf "%7s %5d  (%7.3f kb)\n", "js: ", jsCnt, jsbCnt / 1000
	print ""
	printf "%15s %-5d\n", "Total files: ", fileCnt
	printf "%15s %7.2f kb\n", "Total size: ", byteCnt / 1000
}