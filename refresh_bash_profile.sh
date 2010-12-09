source environment.sh

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
	cp "${git_install}environment.sh" "${gitscripts_path}environment.sh"
	cp "${git_install}bash_profile" "${gitscripts_path}bash_profile"
	cp "${git_install}motd" "${gitscripts_path}motd"
else
	cp "${gitscripts_path}environment.sh" "${git_install}environment.sh"
	cp "${gitscripts_path}bash_profile" "${git_install}bash_profile"
	cp "${gitscripts_path}motd" "${git_install}motd"
fi

source "${git_install}bash_profile"
