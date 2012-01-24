givenflag=""

if [ -n $1 ] && [ "$1" != " " ] && [ "$1" != "" ]
	then
	givenflag=$1
fi



if [ "$givenflag" == "--help" ] || [ "$givenflag" == "-help" ] || [ "$givenflag" == "-h" ] || [ "$givenflag" == "help" ] || [ $givenflag -eq "--h" ]
	then

		echo "##########################################"
		echo "gitscripts : Help "
		echo "##########################################"
		echo
		echo "No help system yet"

		exit 1

fi


echo "##########################################"
echo "gitscripts : Welcome "
echo "##########################################"
echo

echo "Type the number of the choice you want and hit enter"
echo " (1) - View the current aliases"
echo "  2  - Help"
echo "  3  - Refresh your bash profile"
echo "  4  - Git status"
echo "  5  - Abort"
read decision
echo You chose: $decision
if [ -z "$decision" ] || [ $decision -eq 1 ]
	then

	
	alias
	
	
elif [ $decision -eq 2 ]
	then
	echo "Help system"
	echo
elif [ $decision -eq 3 ]
	then
	refresh_bash_profile
elif [ $decision -eq 4 ]
	then
	git status
else
	exit 1
fi


