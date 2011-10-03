#!/bin/bash




git branch -a | grep "$1"
res=$(git branch -a | grep -i "$1" | head -1 | sed 's/fl\///')



echo""
echo "  Checkout ${res}? y (n)"
read YorN
if [ "$YorN" = "y" ]
	then
	${gitscripts_path}checkout.sh ${res}
fi
