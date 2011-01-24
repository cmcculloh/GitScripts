#!/bin/sh

branch="master"
if [ -n $1 ] && [ "$1" != " " ] && [ "$1" != "" ]
	then
	branch=$1
fi

log1=$(git rev-parse --short $branch)
log2=$(git rev-parse --short head)

echo git diff $log1..$log2

