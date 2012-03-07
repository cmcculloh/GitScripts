_show_date()
{
    oldIFS=$IFS    ## Save old value of IFS
    IFS=" -./"     ## Allow splitting on hyphen, period, slash and space
    set -- $*      ## Re-split arguments
    IFS=$oldIFS    ## Restore old IFS

    ## If there are less than 3 arguments, use today's date
    [ $# -ne 3 ] && {
        date_vars  ## Populate date variables (see the next function)
        _SHOW_DATE="$_DAY $MonthAbbrev $YEAR"
        return
    }
    case $DATE_FORMAT in
        dmy) _y=$3     ## day-month-year format
             _m=${2#0}
             _d=${1#0}
             ;;
        mdy) _y=$3     ## month-day-year format
             _m=${1#0}
             _d=${2#0}
             ;;
        *) _y=$1       ## most sensible format
           _m=${2#0}
           _d=${3#0}
           ;;
    esac

    ## Translate number of month into abbreviated name
    set Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
    eval _m=\${$_m}
    _SHOW_DATE="$_d $_m $_y"
}

show_date()
{
    _show_date "$@" && printf "%s\n" "$_SHOW_DATE"
}

date_vars()
{
    eval $(date "$@" "+DATE=%Y-%m-%d
                      YEAR=%Y
                      MONTH=%m
                      DAY=%d
                      TIME=%H:%M:%S
                      HOUR=%H
                      MINUTE=%M
                      SECOND=%S
                      datestamp=%Y-%m-%d_%H.%M.%S
                      DayOfWeek=%a
                      DayOfYear=%j
                      DayNum=%w
                      MonthAbbrev=%b")

    ## Remove leading zeroes for use in arithmetic expressions
    _MONTH=${MONTH#0}
    _DAY=${DAY#0}
    _HOUR=${HOUR#0}
    _MINUTE=${MINUTE#0}
    _SECOND=${SECOND#0}


    ## Sometimes the variable, TODAY, is more appropriate in the context of a
    ## particular script, so it is created as a synonym for $DATE
    TODAY=$DATE

    export DATE YEAR MONTH DAY TODAY TIME HOUR MINUTE SECOND
    export datestamp MonthAbbrev DayOfWeek DayNum
}



split_date()
{
    ## Assign defaults when no variable names are given on the command line
    sd_1=${2:-SD_YEAR}
    sd_2=${3:-SD_MONTH}
    sd_3=${4:-SD_DAY}

    oldIFS=$IFS        ## save current value of field separator
    IFS="-/. $TAB$NL"  ## new value allows date to be supplied in other formats
    set -- $1          ## place the date into the positional parameters
    IFS=$oldIFS        ## restore IFS
    [ $# -lt 3 ] && return 1  ## The date must have 3 fields

    ## Remove leading zeroes and assign to variables
    eval "$sd_1=\"${1#0}\" $sd_2=\"${2#0}\" $sd_3=\"${3#0}\""
}

# Although slower than the following script, The canonical method
# of checking for a leap year would have been a perfectly acceptable
# script in this book, but it is slower than the one below:
# is_leap_year() {
#     ily_year=${1:-`date +%Y`}
#     [ $(( $ily_year % 400)) -eq 0 -o \
#         \( $(( $ily_year % 4)) -eq 0 -a $(( $ily_year % 100)) -ne 0 \) ] && {
#         _IS_LEAP_YEAR=1
#         return 0
#     } || {
#         _IS_LEAP_YEAR=0
#         return 1
#     }
# }

is_leap_year() { ## USAGE: is_leap_year [year]
    ily_year=${1:-$(date +%Y)}
    case $ily_year in
        *0[48] |\
        *[2468][048] |\
        *[13579][26] |\
        *[13579][26]0|\
        *[2468][048]00 |\
        *[13579][26]00 ) _IS_LEAP_YEAR=1
                         return 0 ;;
        *) _IS_LEAP_YEAR=0
           return 1 ;;
    esac
}

_days_in_month()
{
    if [ -n "$1" ]  ## If there's a command-line argument...
    then
      dim_m=$1         ## $1 is the month
      dim_y=$2         ## $2 is the year
    else            ## Otherwise use the current date
      date_vars        ## set date variables (from standard-funcs)
      dim_y=$YEAR
      dim_m=$MONTH
    fi
    case ${dim_m#0} in
        ## For all months except February,
        ## a simple look-up table is all that's needed
        9|4|6|11) _DAYS_IN_MONTH=30 ;; ## 30 days hath September...
        1|3|5|7|8|10|12) _DAYS_IN_MONTH=31 ;;

        ## For February, the year is needed in order to check
        ## whether it is a leap year
        2) is_leap_year ${dim_y:-`date +%Y`} &&
             _DAYS_IN_MONTH=29 || _DAYS_IN_MONTH=28 ;;
        *) return 5 ;;
    esac
}

days_in_month()
{
    _days_in_month "$@" && printf "%s\n" "$_DAYS_IN_MONTH"
}

_date2julian()
{
   ## If there's no date on the command line, use today's date
   case $1 in
        """") date_vars  ## From standard-funcs, Chapter 1
            set -- $TODAY
            ;;
   esac

   ## Break the date into year, month, and day
   split_date ""$1"" d2j_year d2j_month d2j_day || return 2

   ## Since leap years add a day at the end of February,
   ## calculations are done from 1 March 0000 (a fictional year)
   d2j_tmpmonth=$((12 * $d2j_year + $d2j_month - 3))

   ## If it is not yet March, the year is changed to the previous year
   d2j_tmpyear=$(( $d2j_tmpmonth / 12))

   ## The number of days from 1 March 0000 is calculated
   ## and the number of days from 1 Jan. 4713BC is added
   _DATE2JULIAN=$((
        (734 * $d2j_tmpmonth + 15) / 24 -  2 * $d2j_tmpyear + $d2j_tmpyear/4
        - $d2j_tmpyear/100 + $d2j_tmpyear/400 + $d2j_day + 1721119 ))
}

date2julian()
{
    _date2julian ""$1"" && printf ""%s\n"" ""$_DATE2JULIAN""
}

# ISO date from JD number
_julian2date()
{
    ## Check for numeric argument
    case $1 in
        """"|*[!0-9]*) return 1 ;;
    esac

    ## To avoid using decimal fractions, the script uses multiples.
    ## Rather than use 365.25 days per year, 1461 is the number of days
    ## in 4 years; similarly, 146097 is the number of days in 400 years
    j2d_tmpday=$(( $1 - 1721119 ))
    j2d_centuries=$(( (4 * $j2d_tmpday - 1) / 146097))
    j2d_tmpday=$(( $j2d_tmpday + $j2d_centuries - $j2d_centuries/4))
    j2d_year=$(( (4 * $j2d_tmpday - 1) / 1461))
    j2d_tmpday=$(( $j2d_tmpday - (1461 * $j2d_year) / 4))
    j2d_month=$(( (10 * $j2d_tmpday - 5) / 306))
    j2d_day=$(( $j2d_tmpday - (306 * $j2d_month + 5) / 10))
    j2d_month=$(( $j2d_month + 2))
    j2d_year=$(( $j2d_year + $j2d_month/12))
    j2d_month=$(( $j2d_month % 12 + 1))

    ## pad day and month with zeros if necessary
    case $j2d_day in ?) j2d_day=0$j2d_day;; esac
    case $j2d_month in ?) j2d_month=0$j2d_month;; esac

    _JULIAN2DATE=$j2d_year-$j2d_month-$j2d_day
}

julian2date()
{
    _julian2date ""$1"" && printf ""%s\n"" ""$_JULIAN2DATE""
}

_dateshift()
{
    case $# in
        ## If there is only 1 argument, it is the offset
        ## so use today's date
        0|1) ds_offset=${1:-0}
             date_vars
             ds_date=$TODAY
             ;;
        ## ...otherwise the first argument is the date
        "") ds_date=$1
           ds_offset=$2
           ;;
    esac
    while :
    do
       case $ds_offset in
           0*|+*) ds_offset=${ds_offset#?} ;; ## Remove leading zeros or plus signs
           -*) break ;; ## Negative value is OK; exit the loop
           "") ds_offset=0; break ;;          ## Empty offset equals 0; exit loop
           *[!0-9]*) return 1 ;;              ## Contains non-digit; return with error
           *) break ;;                        ## Let's assume it's OK and continue
       esac
    done
    ## Convert to Julian Day
    _date2julian ""$ds_date""
    ## Add offset and convert back to ISO date
    _julian2date $(( $_DATE2JULIAN + $ds_offset ))
    ## Store result
    _DATESHIFT=$_JULIAN2DATE
}

dateshift()
{
    _dateshift ""$@"" && printf ""%s\n"" ""$_DATESHIFT""
}

_yesterday()
{
    _date2julian "$1"
    _julian2date $(( $_DATE2JULIAN - 1 ))
    _YESTERDAY=$_JULIAN2DATE
}

yesterday()
{
    _yesterday "$@" && printf "%s\n" "$_YESTERDAY"
}

_tomorrow()
{
    _date2julian ""$1""
    _julian2date $(( $_DATE2JULIAN + 1 ))
    _TOMORROW=$_JULIAN2DATE
}

tomorrow()
{
    _tomorrow "$@" && printf "%s\n" "$_TOMORROW"
}

_diffdate()
{
    case $# in
        ## If there's only one argument, use today's date
        1) _date2julian "$1"
           dd2=$_DATE2JULIAN
           _date2julian
           dd1=$_DATE2JULIAN
           ;;
        2) _date2julian "$1"
           dd1=$_DATE2JULIAN
           _date2julian "$2"
           dd2=$_DATE2JULIAN
           ;;
    esac
    _DIFFDATE=$(( $dd2 - $dd1 ))
}

diffdate()
{
    _diffdate ""$@"" && printf ""%s\n"" ""$_DIFFDATE""
}
_day_of_week()
{
    _date2julian ""$1""
    _DAY_OF_WEEK=$(( ($_DATE2JULIAN + 1) % 7 ))
}

day_of_week()
{
    _day_of_week ""$1"" && printf ""%s\n"" ""$_DAY_OF_WEEK""
}

## Dayname accepts either 0 or 7 for Sunday, 2-6 for the other days
## or checks against the first three letters, in upper or lower case
_dayname()
{
    case ${1} in
        0|7|[Ss][Uu][Nn]*) _DAYNAME=Sunday ;;
        1|[Mm][Oo][nN]*) _DAYNAME=Monday ;;
        2|[Tt][Uu][Ee]*) _DAYNAME=Tuesday ;;
        3|[Ww][Ee][Dd]*) _DAYNAME=Wednesday ;;
        4|[Tt][Hh][Uu]*) _DAYNAME=Thursday ;;
        5|[Ff][Rr][Ii]*) _DAYNAME=Friday ;;
        6|[Ss][Aa][Tt]*) _DAYNAME=Saturday ;;
        *) return 5 ;; ## No match; return an error
    esac
}

dayname()
{
    _dayname ""$@"" && printf ""%s\n"" "'"$_DAYNAME""
}

display_date()
{
    dd_fmt=WdMy  ## Default format

    ## Parse command-line options for format string
    OPTIND=1
    while getopts f: var
    do
      case $var in
          f) dd_fmt=$OPTARG ;;
      esac
    done
    shift $(( $OPTIND - 1 ))

    ## If there is no date supplied, use today's date
    case $1 in
        """") date_vars ## from standard-funcs in Chapter 1
            set -- $TODAY
            ;;
    esac

    split_date ""$1"" dd_year dd_month dd_day || return 2

    ## Look up long names for day and month
    _day_of_week ""$1""
    _dayname $_DAY_OF_WEEK
    _monthname $dd_month

    ## Print date according to format supplied
    case $dd_fmt in
        WMdy) printf ""%s, %s %d, %d\n"" ""$_DAYNAME"" ""$_MONTHNAME"" \
                     ""$dd_day"" ""$dd_year"" ;;
        dMy)  printf ""%d %s %d\n"" ""$dd_day"" ""$_MONTHNAME"" ""$dd_year"" ;;
        Mdy)  printf ""%s %d, %d\n"" ""$_MONTHNAME"" ""$dd_day"" ""$dd_year"" ;;
        WdMy|*) printf ""%s, %d %s %d\n"" ""$_DAYNAME"" ""$dd_day"" \
                       ""$_MONTHNAME"" ""$dd_year"" ;;
    esac
}

## Set the month number from 1- or 2-digit number, or the name
_monthnum()
{
    case ${1#0} in
         1|[Jj][aA][nN]*) _MONTHNUM=1 ;;
         2|[Ff][Ee][Bb]*) _MONTHNUM=2 ;;
         3|[Mm][Aa][Rr]*) _MONTHNUM=3 ;;
         4|[Aa][Pp][Rr]*) _MONTHNUM=4 ;;
         5|[Mm][Aa][Yy]*) _MONTHNUM=5 ;;
         6|[Jj][Uu][Nn]*) _MONTHNUM=6 ;;
         7|[Jj][Uu][Ll]*) _MONTHNUM=7 ;;
         8|[Aa][Uu][Gg]*) _MONTHNUM=8 ;;
         9|[Ss][Ee][Pp]*) _MONTHNUM=9 ;;
        10|[Oo][Cc][Tt]*) _MONTHNUM=10 ;;
        11|[Nn][Oo][Vv]*) _MONTHNUM=11 ;;
        12|[Dd][Ee][Cc]*) _MONTHNUM=12 ;;
        *) return 5 ;;
    esac
}

monthnum()
{
   _monthnum ""$@"" && printf ""%s\n"" ""$_MONTHNUM""
}

## Set the month name from 1- or 2-digit number, or the name
_monthname()
{
    case ${1#0} in
         1|[Jj][aA][nN]) _MONTHNAME=January ;;
         2|[Ff][Ee][Bb]) _MONTHNAME=February ;;
         3|[Mm][Aa][Rr]) _MONTHNAME=March ;;
         4|[Aa][Pp][Rr]) _MONTHNAME=April ;;
         5|[Mm][Aa][Yy]) _MONTHNAME=May ;;
         6|[Jj][Uu][Nn]) _MONTHNAME=June ;;
         7|[Jj][Uu][Ll]) _MONTHNAME=July ;;
         8|[Aa][Uu][Gg]) _MONTHNAME=August ;;
         9|[Ss][Ee][Pp]) _MONTHNAME=September ;;
        10|[Oo][Cc][Tt]) _MONTHNAME=October ;;
        11|[Nn][Oo][Vv]) _MONTHNAME=November ;;
        12|[Dd][Ee][Cc]) _MONTHNAME=December ;;
        *) return 5 ;;
    esac
}

monthname()
{
    _monthname ""$@"" && printf ""%s\n"" ""${_MONTHNAME}""
}

_parse_date()
{
    ## Clear variables
    _PARSE_DATE=
    pd_DMY=
    pd_day=
    pd_month=
    pd_year=

    ## If no date is supplied, read one from the standard input
    case $1 in
        """") [ -t 0 ] && printf ""Date: "" >&2 ## Prompt only if connected to a terminal
            read pd_date
            set -- $pd_date
            ;;
    esac

    ## Accept yesterday, today and tomorrow as valid dates
    case $1 in
        yes*|-)
            _yesterday && _PARSE_DATE=$_YESTERDAY
            return
            ;;
        tom*|+)
            _tomorrow  && _PARSE_DATE=$_TOMORROW
            return
            ;;
        today|.)
            date_vars && _PARSE_DATE=$TODAY
            return
            ;;
        today*|\
        .[-+1-9]* |\
        [-+][1-9]* )
            pd_=${1#today}
            pd_=${pd_#[-+]}
            _dateshift $pd_ && _PARSE_DATE=$_DATESHIFT
            return
            ;;
    esac

    ## Parse command-line options for date format
    OPTIND=1
    while getopts eiu var
    do
      case $var in
          e) pd_DMY=dmy ;;
          i) pd_DMY=ymd ;;
          u) pd_DMY=mdy ;;
      esac
    done
    shift $(( $OPTIND - 1 ))

    ## Split date into the positional parameters
    oldIFS=$IFS
    IFS='/-. $TAB$NL'
    set -- $*
    IFS=$oldIFS

    ## If date is incomplete, use today's information to complete it
    if [ $# -lt 3 ]
    then
      date_vars
      case $# in
          1) set -- $1 $MONTH $YEAR ;;
          2) set -- $1 $2 $YEAR ;;
      esac
    fi

    case $pd_DMY in
       ## Interpret date according to format if one has been defined
        dmy) pd_day=${1#0}; pd_month=${2#0}; pd_year=$3 ;;
        mdy) pd_day=${2#0}; pd_month=${1#0}; pd_year=$3 ;;
        ymd) pd_day=${3#0}; pd_month=${2#0}; pd_year=$1 ;;

        ## Otherwise make an educated guess
        *) case $1--$2-$3 in
               [0-9][0-9][0-9][0-9]*-*)
                         pd_year=$1
                         pd_month=$2
                         pd_day=$3
                         ;;
               *--[0-9][0-9][0-9][0-9]*-*) ## strange place
                         pd_year=$2
                         _parse_dm $1 $3
                         ;;
               *-[0-9][0-9][0-9][0-9]*)
                         pd_year=$3
                         _parse_dm $1 $2
                         ;;
               *) return 5 ;;
           esac

           ;;
    esac

    ## If necessary, convert month name to number
    case $pd_month in
        [JjFfMmAaSsOoNnDd]*) _monthnum ""$pd_month"" || return 4
                             pd_month=$_MONTHNUM
                             ;;
        *[!0-9]*) return 3 ;;
    esac

    ## Quick check to eliminate invalid day or month
    [ ""${pd_month:-99}"" -gt 12 -o ""${pd_day:-99}"" -gt 31 ] && return 2

    ## Check for valid date, and pad day and month if necessary
    _days_in_month $pd_month $pd_year
    case $pd_day in ?) pd_day=0$pd_day;; esac
    case $pd_month in ?) pd_month=0$pd_month;; esac
    [ ${pd_day#0} -le $_DAYS_IN_MONTH ] &&
                _PARSE_DATE=""$pd_year-$pd_month-$pd_day""
}

parse_date()
{
    _parse_date ""$@"" && printf ""%s\n"" ""$_PARSE_DATE""
}

## Called by _parse_date to determine which argument is the month
## and which is the day
_parse_dm()
{
    ## requires 2 arguments; more will be ignored
    [ $# -lt 2 ] && return 1

    ## if either argument begins with the first letter of a month
    ## it's a month; the other argument is the day
    case $1 in
        [JjFfMmAaSsOoNnDd]*)
             pd_month=$1
             pd_day=$2
             return
             ;;
    esac
    case $2 in
        [JjFfMmAaSsOoNnDd]*)
             pd_month=$2
             pd_day=$1
             return
             ;;
    esac

    ## return error if either arg contains non-numbers
    case $1$2 in *[!0-9]*) return 2;; esac

    ## if either argument is greater than 12, it is the day
    if [ $1 -gt 12 ]
    then
      pd_day=$1
      pd_month=$2
    elif [ ${2:-0} -gt 12 ]
    then
      pd_day=$2
      pd_month=$1
    else
      pd_day=$1
      pd_month=$2
      return 1 ## ambiguous
    fi
}

valid_date()
{
    _date2julian ""$1"" || return 8
    _julian2date $_DATE2JULIAN || return 7
    [ $_JULIAN2DATE = $1 ]
}

