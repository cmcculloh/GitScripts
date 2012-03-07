## /*
#	@description
#	This file is sourced and subsequently sources all files in a given directory.
#	description@
#
#	@notes
#	- The asterisk is outside of the quotes so that it expands as a wildcard.
#	notes@
## */
for file in "${gitscripts_functions_path}"*; do

	if [ ! -d "$file" ] && [ -s "$file" ]; then
		# echo "Going to source: ${file}"
		source $file
	fi

done

cd ${gitscripts_path}

LAST_UPDATE_DATE=`git log -1 --pretty="tformat:%ai"`
LAST_UPDATE_HASH=`git log -1 --pretty="tformat:%h"`
LAST_UPDATE_AUTHOR=`git log -1 --pretty="tformat:%an"`


LAST_UPDATE_DATE=$(date -d '2011-12-31 17:30:24' '+%Y-%m-%d %T')


MPHR=60    # Minutes per hour.
HPD=24     # Hours per day.

diff () {
        printf '%s' $(( $(date -u -d"$TARGET" +%s) -
                        $(date -u -d"$CURRENT" +%s)))
#                       %d = day of month.
}


echo "Last Updated Date: " $LAST_UPDATE_DATE

# __set_remote

# localHash=( `git rev-parse --verify HEAD` )
# remoteHash=( `git rev-parse --verify $_remote/master` )

       LAST_UPDATED=$(date --date="$LAST_UPDATE_DATE" '+%Y-%m-%d %T')
  LAST_UPDATED_YEAR=$(date --date="$LAST_UPDATE_DATE" '+%Y')
 LAST_UPDATED_MONTH=$(date --date="$LAST_UPDATE_DATE" '+%-m')
   LAST_UPDATED_DAY=$(date --date="$LAST_UPDATE_DATE" '+%-d')
  LAST_UPDATED_HOUR=$(date --date="$LAST_UPDATE_DATE" '+%-H')
LAST_UPDATED_MINUTE=$(date --date="$LAST_UPDATE_DATE" '+%-M')


        NOW=$(date '+%Y-%m-%d %T')
   NOW_YEAR=$(date '+%Y')
  NOW_MONTH=$(date '+%-m')
    NOW_DAY=$(date '+%-d')
   NOW_HOUR=$(date '+%-H')
 NOW_MINUTE=$(date '+%-M')
# NOW=$(date +"%Y-%m-%d %T")
# NOW=$(date +"%m-%d-%Y")

echo "LAST_UPDATED: " + $LAST_UPDATED
echo "LAST_UPDATED_YEAR: " + $LAST_UPDATED_YEAR
echo "LAST_UPDATED_MONTH: " + $LAST_UPDATED_MONTH
echo "LAST_UPDATED_DAY: " + $LAST_UPDATED_DAY
echo "LAST_UPDATED_HOUR: " + $LAST_UPDATED_HOUR
echo "LAST_UPDATED_MINUTE: " + $LAST_UPDATED_MINUTE


echo "NOW: " + $NOW
echo "NOW_YEAR: " + $NOW_YEAR
echo "NOW_MONTH: " + $NOW_MONTH
echo "NOW_DAY: " + $NOW_DAY
echo "NOW_HOUR: " + $NOW_HOUR
echo "NOW_MINUTE: " + $NOW_MINUTE

TEMPNAME="${gitscripts_temp_path}gitscripts_auto_updated_last"
echo $LAST_UPDATE_DATE > $TEMPNAME


# y=$(date --date '03 Oct' +%j)
# x=$(date +%j)

# ((z=${y} - ${x}))



# echo "You have ${z} days until your anniversary"


# ((UPDATED_DIFFERENCE_YEAR=${NOW_YEAR} - ${LAST_UPDATED_YEAR}))
# ((UPDATED_DIFFERENCE_MONTH=${NOW_MONTH} - ${LAST_UPDATED_MONTH}))
# ((UPDATED_DIFFERENCE_DAY=${NOW_DAY} - ${LAST_UPDATED_DAY}))
# ((UPDATED_DIFFERENCE_HOUR=${NOW_HOUR} - ${LAST_UPDATED_HOUR}))
# ((UPDATED_DIFFERENCE_MINUTE=${NOW_MINUTE} - ${LAST_UPDATED_MINUTE}))

# echo "Updated Last: " $LAST_UPDATE_DATE
# echo "Now: " $NOW

# # difference=$(date --date='${updatedDiff}' '+%F')
# echo "You updated GitScripts ${UPDATED_DIFFERENCE_YEAR} years ago."
# echo "You updated GitScripts ${UPDATED_DIFFERENCE_MONTH} months ago."
# echo "You updated GitScripts ${UPDATED_DIFFERENCE_DAY} days ago."
# echo "You updated GitScripts ${UPDATED_DIFFERENCE_HOUR} hours ago."
# echo "You updated GitScripts ${UPDATED_DIFFERENCE_MINUTE} minutes ago."



diffdate "${NOW} ${LAST_UPDATE_DATE}"


# TARGET=$(date -d '2017-09-01 17:30:24' '+%Y-%m-%d %T')
# CURRENT=$(date +"%Y-%m-%d %T")



# # TARGET=$(date -u -d'2007-12-25 12:30:00' '+%F %T.%N %Z')
# # %F = full date, %T = %H:%M:%S, %N = nanoseconds, %Z = time zone.

# printf '\nIn 2007, %s ' "$(date -d"$CURRENT + $(( $(diff) /$MPHR /$MPHR /$HPD / 2 )) days" '+%d %B')" 
# #       %B = name of month                ^ halfway
# printf 'was halfway between %s ' "$(date -d"$CURRENT" '+%d %B')"
# printf 'and %s\n' "$(date -d"$TARGET" '+%d %B')"

# printf '\nOn %s at %s, there were: ' $(date -u -d"$CURRENT" +%F) $(date -u -d"$CURRENT" +%T)

# DAYS=$(( $(diff) / $MPHR / $MPHR / $HPD ))
# CURRENT=$(date -d"$CURRENT +$DAYS days" '+%F %T.%N %Z')
# HOURS=$(( $(diff) / $MPHR / $MPHR ))
# CURRENT=$(date -d"$CURRENT +$HOURS hours" '+%F %T.%N %Z')
# MINUTES=$(( $(diff) / $MPHR ))
# CURRENT=$(date -d"$CURRENT +$MINUTES minutes" '+%F %T.%N %Z')
# printf '%s days, %s hours, ' "$DAYS" "$HOURS"
# printf '%s minutes, and %s seconds ' "$MINUTES" "$(diff)"
# printf 'until Christmas Dinner!\n\n'



# # git fetch --all --prune
# # git merge $_remote/master
