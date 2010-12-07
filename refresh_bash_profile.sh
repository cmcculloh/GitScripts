direction="to"
destination="local"
if [ -n $1 ]
	then
	direction=$1
fi
if [ -n $2 ]
	then
	destination=$2
fi

command=$direction$destination

if [ "$command" = "fromlocal" -o "$command" = "togit" ]
	then
	cp /c/Program\ Files/Git/etc/bash_profile /d/automata/flgitscripts/bash_profile
else
	cp /d/automata/flgitscripts/bash_profile /c/Program\ Files/Git/etc/bash_profile
fi

source /c/Program\ Files/Git/etc/bash_profile
