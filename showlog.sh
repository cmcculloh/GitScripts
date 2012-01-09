#!/bin/sh
$loadfuncs


echo
branch="master"
if [ -n "$1" ]; then
	branch=$1
	if ! __branch_exists $branch; then
		echo ${E}"  Branch \`$branch\` does not exist! Aborting...  "
		exit 1
	fi
fi


hashFrom=$(git rev-parse --short $branch)
hashTo=$(git rev-parse --short HEAD)

echo ${O}${H2HL}
echo "$ git diff --name-status $hashFrom..$hashTo"
echo
git diff --name-status $hashFrom..$hashTo
echo
echo "git diff -w $hashFrom..$hashTo"
echo ${H2HL}${X}
echo
echo ${Q}"Do diff? y (n)"${X}
read yn
if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
	git diff -w $hashFrom..$hashTo
fi

exit
