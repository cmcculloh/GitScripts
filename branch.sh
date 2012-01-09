#!/bin/bash


git branch -a | grep "$1"
remotes_string=$(git branch -a | grep "$1" | sed 's/fl\///' | sed 's/remotes\///');
c=0;

last=""
for remote in $remotes_string; 
do 
#echo "$c: $remote";
r=$(echo $remote)
if [ "$last" != "$r" ]; then
	remotes[$c]=$r;
	c=$((c+1));
fi

last=$r
done

if [ ${#remotes[@]} -gt 1 ]
	then
	echo ${O}"------------------------------------------------------------------------------------"
	echo "Choose a branch (or just hit enter to abort):"
	echo "------------------------------------------------------------------------------------"
	for (( i = 0 ; i < ${#remotes[@]} ; i++ ))
		do
		remote=$(echo ${remotes[$i]} | sed 's/[a-zA-Z0-9\-]+(\/\{1\}[a-zA-Z0-9\-]+)//p')

		if [ $i -le "9" ] ; then
			index="  "$i
		elif [ $i -le "99" ] ; then
			index=" "$i
		else
			index=$i
		fi
		echo "$index: $remote"
	done
	echo ${I}"Choose a branch (or just hit enter to abort):"
	read remote
	echo ${X}

	if [ -n "$remote" ]; then
		remote=$(echo ${remotes[$remote]} | sed 's/[a-z]*\///g')
	else
		echo "no branch chosen, aborting"
		exit 0
	fi
fi


if [ -n "$remote" ]; then
	echo""
	echo "  Checkout ${remote}? y (n)"
	read YorN
	if [ "$YorN" = "y" ]
		then
		${gitscripts_path}checkout.sh ${remote}
	fi
else
	echo "no known branches on any remotes match or contain that name"
fi