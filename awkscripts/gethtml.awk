BEGIN {
	mediasrc = "/media/landing-pages/" promouri "/"
	mediaimgsrc = mediasrc "images/"
	print "<link type=\"text/css\" rel=\"stylesheet\" href=\"/media/landing-pages/" promouri "/css/styles.css\"/>"
}
/<body/ {
	endofhtml = "false"
	while (endofhtml == "false" && getline line) {
		if (line ~ /<[/]body>/) {
			endofhtml = "true"
		}
		else {
			# replace unix line endings with windows...
			gsub(/$/,"\r",line)

			# make sure media urls are pointing to the right place
			gsub(/ src="/," src=\"" mediasrc, line)
			gsub(/url\(/,"url(" mediasrc, line)
			gsub(/ background="/," background=\"" mediasrc, line)

			# if the images directory wasn't already included, include it
			if (line !~ mediaimgsrc) gsub(mediasrc,mediaimgsrc,line)

			# make sure anchor urls are relative to root
			gsub(/href=\"http:[/]+www\.finishline\.com/,"href=\"",line)

			print line
		}
	}
}