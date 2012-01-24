#!/bin/bash

thisHostname=hostname;

if [ $thisHostname = "flqap102.finishline.com" ]; then
	echo "we are at 102";
else
	# import developer workstation settings
	source "${flgitscripts_path}refresh_bash_profile.sh"
fi

