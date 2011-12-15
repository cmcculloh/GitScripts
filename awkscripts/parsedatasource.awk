# This will grab the contents in between a single pair of
# open/close xml tags. For instance, it will grab the string
# "hello" from the following input:
#		<sometag>hello</sometag>

function tagContents(string) {
	isMatch = match(string, />.+<\//)
	name = (isMatch > 0) ? substr(string, RSTART + 1, RLENGTH - 3) : ""
	return name
}


/^ *<jndi-name/ {
	jname = tagContents($0)

	do {
		getline nl
		if (nl ~ /^ *<connection-url/) {
			connUrl = tagContents(nl)

			# grab ip/port string
			match(connUrl, /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+/)
			ipAndPort = substr(connUrl,RSTART,RLENGTH)
			split(ipAndPort,pcs,/:/)
			ip = pcs[1]
			port = pcs[2]

			# determine if table is on qa or stage
			if (ip ~ /\.25$/) env = "qa(1)"
			if (ip ~ /\.26$/) env = "qa(2)"
			if (ip ~ /\.201$/) env = "stage(1)"
			if (ip ~ /\.202$/) env = "stage(2)"
			if (env == "") env = "unknown"

			# grab table name
			match(connUrl, /=.+$/)
			table = substr(connUrl,RSTART + 1)

			printf pfmt, jname, ip, port, env, table
			#print "connUrl: " connUrl
			#print "IP: " ip
			#print "Port: " port
			#print "Table: " table
			#print ""
		}
	} while (nl !~ /\/local-tx-datasource/)
}