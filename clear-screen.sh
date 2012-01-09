#!/bin/bash


echo
if [ "$clearscreenanswer" == "n" ] || [ "$clearscreenanswer" == "N" ]; 	then
	defO=" y (n)"
	defA="n"
else
	defO=" (y) n"
	defA="y"
fi

echo ${I}"Clear screen?"${defO}${X};
read yn

if [ -z "$YorN" ]; then
	yn=$defA
fi

if [ "$yn" == "y" ]; then
	clear
fi