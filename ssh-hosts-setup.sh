#!/bin/bash

# Tilde (~) expansion for home directory not reliable in quotes.
config_path=`cd ~; pwd`"/.ssh/"
config="${config_path}config"
configbak="${config}.bak"
flgs_tag="# Edited by ssh-hosts-setup.sh"
keys=(riddle_key)
riddle_key_in="${inputdir}_riddle_key"
riddle_key="${config_path}riddle_key"


# Function for writing to the config file.
function write_config {
	cat > $config <<CONFIGINPUT
$flgs_tag

# Community user key. (i.e. used for phone)
Host $HOST_RIDDLE
	User et
	IdentityFile ~/.ssh/riddle_key

CONFIGINPUT
}


# make sure path exists and can be created. if the path can be created, so can any files within it.
keyexists=false
numkeys=0
echo
echo ${O}${H2HL}
if [ ! -d $config_path ]; then
	echo "> Path to ssh config missing."
	echo -n "Attempting to create ${config_path} ..."
	mkdir $config_path
	if [ ! -d $config_path ]; then
		echo
		echo ${E}"You appear to not have permission to create a directory in your home folder!"${X}
		exit 1
	fi
	echo 'done.'
else
	# directory exists, now check for keys
	echo "> Path to config found: ${config_path}"
	echo -n "> Collecting any key pairs by searching for public keys..."
	keyfile=$(cd ${config_path}; ls *.pub)
	if [ -n "$keyfile" ]; then
		keyexists=true

		# now figure out how many there are
		for i in $keyfile; do
			(( numkeys++ ))
		done
	fi
	echo "done."
	echo "> FLGitScripts found ${numkeys} key(s)."
fi


# if an existing config file exists, a backup should be made regardless of whether or not in contains anything.
if [ -s "$config" ]; then
	# config may have already been edited. prevent endless Host definitions...
	{ cat $config | grep -q "$flgs_tag"; } && {
		echo ${X}${COL_YELLOW}"! File already edited by this script. Further changes must be manual. Exiting..."${X}
		echo ${O}${H2HL}${X}
		exit 1
	}

	echo -n "> Backing up current config file..."
	{ cp -b $config "${configbak}"; } && { echo "done."; } || {
		echo "failed. Unable to make backup. Continue anyway? y (n)"
		read yn
		if [ -z "$yn" ] || [ "$yn" == "n" ] || [ "$yn" == "N"]; then
			exit 1
		fi
		return 0
	}
else
	echo -n "> Touching ${config}..."
	touch $config
	echo "done."
fi


# move over any keys flgs requires...
for j in ${keys[@]}; do
	key_in_path="${inputdir}_$j"
	key_path="${config_path}$j"
	echo "> Copying key: $key_path"
	if [ -s $key_in_path ]; then
		{ cp -f $key_in_path $key_path; } || {
			echo ${E}"Unable to copy key. Some scripts may not function properly without this key..."${X}${O}
		}
	else
		echo ${E}"Unable to find key. Some scripts may not function properly without this key..."${X}${O}
	fi
done


echo -n "> Configuring ssh hosts..."

# check for Host definitions in the config file. some default config files specify only a single
# IdentityFile. If that is the case, or if the config file is empty, we will create it from scratch.
configexists=$(grep 'Host' < $config)
write_config
if [ -z "$configexists" ]; then

	# if user already has a key, it is probably id_rsa/id_dsa so specify it for all other hosts
	if [ "$keyexists" == "true" ] && [ $numkeys -eq 1 ]; then
		keyname=$(echo $keyfile | awk '{ gsub(/\.pub$/,""); print }')

		cat >> $config <<CONFIGINPUT
# Universal key (pre-existing)
Host *
	IdentityFile ~/.ssh/$keyname

CONFIGINPUT

		echo "done."
		echo ${H2HL}${X}

	elif [ $numkeys -gt 1 ]; then
		#there is more than one key and the user may require special configuration
		echo "partially complete."
		echo ${H2HL}${X}
		echo
		echo "There is more than one key present, but there is no Host distinction in your config file."
		echo "You will need to manually specify your global key (and any others) in your HOME/.ssh/config file."
		echo "Here is an example:"
		echo ${COL_YELLOW}
		echo "	## The asterisk (*) catches all hosts, so this should be at the end of the file."
		echo "	Host *"
		echo "		IdentityFile ~/.ssh/KEYNAME"
		echo ${COL_NORM}
		echo "Your config file is located at: $config"
	fi

else
	# user has already configured some hosts. we have already added on to the top of the config file.
	# copy the original file onto the end of the new file. $configbak is guaranteed to exist.
	cat >> $config < $configbak
	echo "done."
	echo ${H2HL}${X}
fi

exit