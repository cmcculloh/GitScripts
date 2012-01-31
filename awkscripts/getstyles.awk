/<style/ {
	endofstyles = "false"
	while (endofstyles == "false" && getline line) {
		if (line ~ /<[/]style>/) {
			endofstyles = "true"
		}
		else {
			# replace unix line endings with windows...
			gsub(/$/,"\r",line)

			print line
		}
	}
}