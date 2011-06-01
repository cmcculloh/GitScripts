#!/bin/bash

# cpafter.sh: Copies files modified on or after a given date, along with dirs.
#             (requires copy_it.sh)
#
# Copyright (C) 2007  Scott Carpenter
#                     http://www.movingtofreedom.org
#                     scottc (at) movingtofreedom (dot) org
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details:
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/.

 usage="\nCopies files modified on or after the given date from source dir\n"
usage+="to target dir, creating any subdirectories as needed.\n\n"
usage+="\tusage: cpafter.sh [-vf] -a after_date_YYYYMMDD -s source_dir -t target_dir\n"
usage+="\t\t-v verbose\n"
usage+="\t\t-f force target dir creation or copying to non-empty target dir\n"

while getopts ":vfa:s:t:" opt
do
	case $opt in
		v  ) verbose=" -v " ;;
		f  ) force="true" ;;
		a  ) after_date=$OPTARG ;;
		s  ) from_dir=$OPTARG ;;
		t  ) to_dir=$OPTARG ;;
		\? ) echo -e $usage
		     exit 1
	esac
done
shift $(($OPTIND - 1))

if [[ -z "$after_date" || -z "$from_dir" || -z "$to_dir" || $# -ne 0 ]]; then
	echo -e $usage
	exit 1
fi

if [[ ! -d "$from_dir" ]]; then
	echo "source dir does not exist"
	bail="true"
fi

if [[ ! -d "$to_dir" ]]; then
	if [[ -z "$force" ]]; then
		echo "target dir does not exist (use -f to force mkdir)"
		bail="true"
	elif [[ -z "$bail" ]]; then
		if [[ -n "$verbose" ]]; then
			echo "making target dir $to_dir"
		fi
		mkdir -p $to_dir
	fi
fi

if [[ -d "$to_dir" && -n "$(ls $to_dir)" ]]; then
	if [[ -z "$force" ]]; then
		echo "target dir is not empty (use -f to force copy to non-empty dir)"
		bail="true"
	fi
fi

if [[ -n "$bail" ]]; then
	exit 1
fi

after_date_epochal=$(date -d $after_date +%s)

today=$(date +%Y%m%d)
today_epochal=$(date -d $today +%s)

if (($today < $after_date)); then
	echo "after_date $after_date is after today ($today)"
	exit 1
fi

# subtract backwards to get negative number needed for find -mtime
# (negative number gives all files from N days back to now)
# (subtract one additional because of using -daystart option, which starts
#  from midnight instead of the current time)

date_dif=$(( (($after_date_epochal - $today_epochal) / 60 / 60 / 24) - 1))

#echo "debug: date_dif is $date_dif"

orig_dir=$PWD

#there must be a better way to make sure we have absolute path of target
cd $to_dir
to_dir=$PWD
cd $orig_dir

cd $from_dir

if [[ -n "$verbose" ]]; then
	echo -e "\ncopying from $PWD\n\tto $to_dir\n"
fi

find . -type f -daystart -mtime $date_dif -exec copy_it.sh $verbose -s {} -t $to_dir \;
find . -type l -daystart -mtime $date_dif -exec copy_it.sh $verbose -s {} -t $to_dir \;

cd $orig_dir
