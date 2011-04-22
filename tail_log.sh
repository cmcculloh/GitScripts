echo "you have chosen to tail $1"

if [ -z "$1" ]
	then
	tail -f ${JBOSS_LOGS}genericinfo.log
else
	tail -f ${JBOSS_LOGS}$1.log
fi