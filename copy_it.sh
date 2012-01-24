#!/bin/bash

# copy_it.sh: Copies file to target dir, creating parent dirs if necessary.
#             (intended to be called from cpafter.sh)
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

usage="\nCopies a file to a dir, using the path information from the file to\n"
usage+="build a path from the given dir root if necessary. Meant to be used\n"
usage+="with cpafter.sh.\n\n"
usage+="\tusage: copy_it.sh [-v] -s source_file -t target_directory_root\n"
usage+="\t\t-v verbose (just lists the source file)\n"

while getopts ":vs:t:" opt
do
	case $opt in
		v  ) verbose=true ;;
		s  ) from_file=$OPTARG ;;
		t  ) to_dir=$OPTARG ;;
		\? ) echo -e $usage
		     exit 1
	esac
done
shift $(($OPTIND - 1))

if [[ -z "$from_file" || -z "$to_dir" ]]; then
	echo -e $usage
	exit 1
fi

curdir=$PWD		#from_dir

#regex -- does string start with dot slash?
#if [[ ! "$from_file" =~ ^\./ ]];
#	then
#		from_file="./$from_file"
#	#in case only a filename was given
#fi

#return $from_file up to (but not including) last slash
add_to_target=${from_file%/*}

#echo "debug: copy_it: old file: $curdir/$from_file"
#echo "debug: copy_it: mkdir -p $to_dir/${BASH_REMATCH[1]}"
#echo "debug: copy_it: new file: $to_dir/$from_file"
#echo "debug: copy_it: cp -pdf \"$curdir/$from_file\" \"$to_dir/$from_file\""
#echo

if [[ ! -d "$to_dir/$add_to_target" ]]; then

	if [ -n "$verbose" ]; then
		#here and below, remove $to_dir/ for a cleaner listing
		msg="(mkdir) $to_dir/$add_to_target"
		#bash built-in substitution ${variable/pattern_to_match/replacement_string}
		echo "${msg/$to_dir\//}"
	fi
	mkdir -p "$to_dir/$add_to_target"
fi
cp -pdf "$curdir/$from_file" "$to_dir/$from_file"

if [ -n "$verbose" ]; then
	msg="$to_dir/$from_file"
	echo "${msg/$to_dir\//}"
fi

#notes
#-need "" around filenames in cp and mkdir to handle files with spaces in the name
