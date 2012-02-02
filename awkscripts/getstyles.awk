BEGIN {
	mediasrc = "/media/landing-pages/" promouri "/"
	mediaimgsrc = mediasrc "images/"
}
/<style/ {
	endofstyles = "false"
	while (endofstyles == "false" && getline line) {
		if (line ~ /<[/]style>/) {
			endofstyles = "true"
		}
		else {
			# replace unix line endings with windows...
			gsub(/$/,"\r",line)

			# update image uris
			gsub(/url\(/,"url(" mediasrc, line)

			# if the images directory wasn't already included, include it
			if (line !~ mediaimgsrc) gsub(mediasrc,mediaimgsrc,line)

			print line
		}
	}
}