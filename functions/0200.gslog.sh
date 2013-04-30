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
#	@file functions/0200.gslog.sh
## */
function __gslog {
	if [ $# -gt 0 ] && [ -f "$gitscripts_log" ]; then
		echo >> $gitscripts_log
		echo "###################################  "$(date)"  ###################################" >> $gitscripts_log
		echo >> $gitscripts_log
		until [ -z "$1" ]; do
			echo "$1" >> $gitscripts_log
			shift 1
		done
		echo >> $gitscripts_log
		echo >> $gitscripts_log
	fi
}
