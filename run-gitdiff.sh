#!/bin/sh

branch="master"
if [ -n $1 ] && [ "$1" != " " ] && [ "$1" != "" ]
    then
    branch=$1
fi

log1=$(git rev-parse --short $branch)
log2=$(git rev-parse --short head)

echo Git diff:
echo =========================
echo git diff $log1..$log2
echo -------------------------
echo "Run it? (y) n "
read decision
if [ -z $decision ]
    then
    git diff $log1..$log2
    exit 0
elif [ $decision = "y" ]
    then
    git diff $log1..$log2
    exit 0
else
    echo Aborting...
    echo
    exit 1
fi




