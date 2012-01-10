## /* @function
#	@usage __gslog <data>
#
#	@output file
#
#	@description
#	A custom logger for GitScripts. Usually failure messages that aren't useful to the user, but may be to
#	a developer will be put here as opposed to echoed to standard output.
#	description@
#
#	@notes
#	- Appends to log file only if a parameter is given and log file exists.
#	notes@
#
#	@examples
#	1) __gslog "starting my script..."
#	2) if [ $myage -lt 40 ]; then __gslog "You've still got time..."; fi
#	examples@
#
#	@dependencies
#	[vars] $gslog (path to log file)
#	dependencies@
## */
function __gslog {
	if [ -n "$1" -a -f "$gitscripts_log" ]; then
		echo >> $gitscripts_log
		echo "###################################  "$(date)"  ###################################" >> $gitscripts_log
		echo >> $gitscripts_log
		echo $1 >> $gitscripts_log
		echo >> $gitscripts_log
		echo >> $gitscripts_log
	fi
}