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

# cd ${gitscripts_path}



# MPHR=60    # Minutes per hour.
# HPD=24     # Hours per day.

# diff () {
#         printf '%s' $(( $(date -u -d"$TARGET" +%s) -
#                         $(date -u -d"$CURRENT" +%s)))
# #                       %d = day of month.
# }


# # __set_remote

# # localHash=( `git rev-parse --verify HEAD` )
# # remoteHash=( `git rev-parse --verify $_remote/master` )

#        LAST_UPDATED=$(date --date='2012-03-01 13:27:52' '+%Y-%m-%d %T')
#   LAST_UPDATED_YEAR=$(date --date='2012-03-01 13:27:52' '+%Y')
#  LAST_UPDATED_MONTH=$(date --date='2012-03-01 13:27:52' '+%m')
#    LAST_UPDATED_DAY=$(date --date='2012-03-01 13:27:52' '+%d')
#   LAST_UPDATED_HOUR=$(date --date='2012-03-01 13:27:52' '+%H')
# LAST_UPDATED_MINUTE=$(date --date='2012-03-01 13:27:52' '+%M')


#         NOW=$(date '+%Y-%m-%d %T')
#    NOW_YEAR=$(date '+%Y')
#   NOW_MONTH=$(date '+%m')
#     NOW_DAY=$(date '+%d')
#    NOW_HOUR=$(date '+%H')
#  NOW_MINUTE=$(date '+%M')
# # NOW=$(date +"%Y-%m-%d %T")
# # NOW=$(date +"%m-%d-%Y")




# TEMPNAME="${gitscripts_temp_path}gitscripts_auto_updated_last"
# echo $NOW > $TEMPNAME


# # y=$(date --date '03 Oct' +%j)
# # x=$(date +%j)

# # ((z=${y} - ${x}))



# # echo "You have ${z} days until your anniversary"


# ((UPDATED_DIFFERENCE_YEAR=${NOW_YEAR} - ${LAST_UPDATED_YEAR}))
# ((UPDATED_DIFFERENCE_MONTH=${NOW_MONTH} - ${LAST_UPDATED_MONTH}))
# ((UPDATED_DIFFERENCE_DAY=${NOW_DAY} - ${LAST_UPDATED_DAY}))
# ((UPDATED_DIFFERENCE_HOUR=${NOW_HOUR} - ${LAST_UPDATED_HOUR}))
# ((UPDATED_DIFFERENCE_MINUTE=${NOW_MINUTE} - ${LAST_UPDATED_MINUTE}))

# echo "Updated Last: " $LAST_UPDATED
# echo "Now: " $NOW

# # difference=$(date --date='${updatedDiff}' '+%F')
# echo "You updated GitScripts ${UPDATED_DIFFERENCE_YEAR} years ago."
# echo "You updated GitScripts ${UPDATED_DIFFERENCE_MONTH} months ago."
# echo "You updated GitScripts ${UPDATED_DIFFERENCE_DAY} days ago."
# echo "You updated GitScripts ${UPDATED_DIFFERENCE_HOUR} hours ago."
# echo "You updated GitScripts ${UPDATED_DIFFERENCE_MINUTE} minutes ago."



# TARGET=$(date -d '2007-09-01 17:30:24' '+%Y-%m-%d %T')
# CURRENT=$(date +"%Y-%m-%d %T")



# # TARGET=$(date -u -d'2007-12-25 12:30:00' '+%F %T.%N %Z')
# # %F = full date, %T = %H:%M:%S, %N = nanoseconds, %Z = time zone.

# printf '\nIn 2007, %s ' "$(date -d"$CURRENT + $(( $(diff) /$MPHR /$MPHR /$HPD / 2 )) days" '+%d %B')" 
# #       %B = name of month                ^ halfway
# printf 'was halfway between %s ' "$(date -d"$CURRENT" '+%d %B')"
# printf 'and %s\n' "$(date -d"$TARGET" '+%d %B')"

# printf '\nOn %s at %s, there were: 

# ' $(date -u -d"$CURRENT" +%F) $(date -u -d"$CURRENT" +%T)

# DAYS=$(( $(diff) / $MPHR / $MPHR / $HPD ))
# CURRENT=$(date -d"$CURRENT +$DAYS days" '+%F %T.%N %Z')
# HOURS=$(( $(diff) / $MPHR / $MPHR ))
# CURRENT=$(date -d"$CURRENT +$HOURS hours" '+%F %T.%N %Z')
# MINUTES=$(( $(diff) / $MPHR ))
# CURRENT=$(date -d"$CURRENT +$MINUTES minutes" '+%F %T.%N %Z')
# printf '%s days, %s hours, ' "$DAYS" "$HOURS"
# printf '%s minutes, and %s seconds ' "$MINUTES" "$(diff)"
# printf 'until Christmas Dinner!\n\n'



# git fetch --all --prune
# git merge $_remote/master
