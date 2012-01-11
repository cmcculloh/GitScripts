#!/bin/sh

# diff is called by git with 7 parameters:
#  path old-file old-hex old-mode new-file new-hex new-mode
#  $1   $2       $3      $4       $5       $6      $7


# echo "Path: $1"
# echo "Old File: $2"
# echo "New File: $5"
# echo "Old Mode: $4"
# echo "New Mode: $7"
#"C:/Program Files/SourceGear/DiffMerge/DiffMerge.exe" "$2" "$5" | cat
#"C:/Program Files/WinMerge/WinMergeU.exe" "$2" "$5" | cat


# works -- but sends images too
# echo "C:/Program Files (x86)/KDiff3/kdiff3.exe" "$2" "$5" | cat
# "C:/Program Files (x86)/KDiff3/kdiff3.exe" "$2" "$5" | cat


# this_file_ext="$1"|awk -F . '{print $NF}'

file="$1"
#echo "filename: ${file%.*}"
#echo "extension: ${file##*.}"
#filename="${file%.*}"
extension="${file##*.}"

# echo "extension: " $extension


if [[ "$2" == '/dev/null' ]]
  then
	oldfile="NUL"
else
	oldfile=$2
fi

if [[ "$5" == '/dev/null' ]]
  then
	newfile="NUL"
else
	newfile=$5
fi


if [[ "$extension" == png ]]
  then
	"${TORTOISE_BIN}TortoiseIDiff.exe" /left:"$oldfile" /right:"$newfile" /fit /overlay
else
	"${TORTOISE_BIN}TortoiseMerge.exe" $oldfile $newfile
fi




# t_base="/base:\"$2\""
# t_local="/mine:\"$5\""
# t_remote="/theirs:\"c:\folder\$3\""
# t_merge_result="/merged:\"c:\folder\$4\""




# /left:"c:\images\img1.jpg" /lefttitle:"image 1" /right:"c:\images\img2.jpg" /righttitle:"image 2" /fit /overlay

# "C:/Program Files/TortoiseGit/bin/TortoiseIDiff.exe" "$2" "$5" | cat


#"TortoiseMerge $t_base $t_local $t_remote" | cat
# "C:/Program Files/TortoiseGit/bin/TortoiseMerge.exe $t_base $t_local $t_remote" | cat

#echo ""

