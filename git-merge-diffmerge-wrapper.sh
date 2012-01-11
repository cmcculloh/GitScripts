#!/bin/sh

# Passing the following parameters to mergetool:
#  local base remote merge_result

	echo "Merge Result: " $4


#"C:/Program Files/SourceGear/DiffMerge/DiffMerge.exe" "$1" "$2" "$3" --result="$4" --title1="Mine" --title2="Merging to: $4" --title3="Theirs"


# TortoiseMerge BaseFilePath MyFilePath [ TheirFilePath ]




file="$2"
#echo "filename: ${file%.*}"
#echo "extension: ${file##*.}"
#filename="${file%.*}"
extension="${file##*.}"

# echo "extension: " $extension


if [[ "$1" == '/dev/null' ]]
  then
	myfile="NUL"
else
	myfile=$1
fi

if [[ "$2" == '/dev/null' ]]
  then
	basefile="NUL"
else
	basefile=$2
fi

if [[ "$3" == '/dev/null' ]]
  then
	remotefile="NUL"
else
	remotefile=$3
fi


if [[ "$extension" == png ]]
  then
	"${TORTOISE_BIN}TortoiseIDiff.exe" $basefile $myfile $remotefile
else
	"${TORTOISE_BIN}TortoiseMerge.exe" $basefile $myfile $remotefile
fi



# works, but leaves orig files behind
# "C:/Program Files/TortoiseGit/bin/TortoiseMerge.exe" "$1" "$2" "$3" --result="$4" --title1="Mine" --title2="Merging to: $4" --title3="Theirs"
# echo "C:/Program Files/TortoiseGit/bin/TortoiseMerge.exe" "$1" "$2" "$3" --result="$4" --title1="Mine" --title2="Merging to: $4" --title3="Theirs"
