#!/bin/sh

branch="master"
if [ -n $1 ] && [ "$1" != " " ] && [ "$1" != "" ]
	then
	branch=$1
fi

log1=$(git rev-parse --short $branch)
log2=$(git rev-parse --short head)

echo git diff --name-status $log1..$log2
echo "Do name-status only diff? y (n) "
read decision
if [ "$decision" ] && [ $decision = "y" ]
    then
	echo "to exit, hit q"
    git diff --summary $log1..$log2
fi

echo
echo
echo git diff $log1..$log2

echo "Do diff? y (n) "
read decision
if [ "$decision" ] && [ $decision = "y" ]
    then
    git diff $log1..$log2
fi
