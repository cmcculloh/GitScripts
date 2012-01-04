#this file is entirely for example purposes only. It illustrates
#how to work with for in loops with fake arrays created by
#the output of git commands, and how to translate them into
#real arrays usable in gitscripts

remotes_string=$(git remote);
c=0;

for i in $remotes_string; 
do 
echo "$c: $i";
c=$((c+1));
remotes[$c]=$i;
done

if [ $c -eq 1 ]
	then
	echo "c is 1"
else
	echo "c is greater than 1"
	echo "c: $c"
fi

echo "remotes[1]: ${remotes[1]}"

if [ ${#remotes[@]} -eq 1 ]
	then
	echo "array is (1) ${#remotes[@]} elements long"
else
	echo "array is ${#remotes[@]} elements long"
fi