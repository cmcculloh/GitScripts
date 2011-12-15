BEGIN {
	used = "/d/workspaces/helios_workspace/myscripts/output/docsUsed"
	unused = "/d/workspaces/helios_workspace/myscripts/output/docsNOTused"

	print "" >> used
	print "" >> used
	print "" >> used
	print ":|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:" >> used
	print "" >> used
	print "		web-app.war/" dir >> used
	print "" >> used
	print "..............................................................................................................." >> used
	print "" >> used

	print "" >> unused
	print "" >> unused
	print "" >> unused
	print ":|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:|:" >> unused
	print "" >> unused
	print "		web-app.war/" dir >> unused
	print "" >> unused
	print "..............................................................................................................." >> unused
	print "" >> unused
}

# don't search media files
/\.jspf?$|\.html?$|\.txt$|\.xml$/ {
	# get just the file name and extension
	pieces = split($0,arr,"/")
	file = arr[pieces] "[^a-zA-Z]"

	# escape periods and make sure extension is the end of the pattern
	gsub(/\./,"\\.",file)

	# create an entry with just the parent directory prepended
	num = split(dir,arr,"/")
	parent = arr[num]

	# this will be grepped so periods need to be escaped
	print "\"[^/]" file "\""
	print "\"\\.\\./" file "\""
	print "\"" parent "/" file "\""
}