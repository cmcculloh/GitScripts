#!/bin/bash

# This script takes care of bringing 102 up to date with an .ear,
# while taking care to backup and restore any submodules that
# outside vendors have access to.
$loadfuncs
thisHostname=hostname;

if [ $thisHostname = "flqap102.finishline.com" ]; then
	echo "We are at 102";
	instancename="03finishline"
	JBOSS_LOG_FILE="/opt/jboss/server/${instancename}/log/server.log"

else
	echo "We are not at 102";
	instancename="alt_finishline"
	JBOSS_LOG_FILE="/home/pjc/Development/opt/jboss-4.0.5.GA/server/${instancename}/log/server.log"
	# import developer workstation settings
	source "${flgitscripts_path}refresh_bash_profile.sh"
fi





# /adidas-shoes is a symlink (adidas-shoes -> /opt/jboss/server/03finishline/deploy/finishline.ear/web-app.war/global/promos/adidas-shoes/)
# /adidas-shoes is a checkout of the adidas-shoes.git repository


# cd into the adidas-shoes directory
cd "/adidas-shoes"

changesWereStashed="false"

# make note of what branch is currently checked out
current_branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')

echo "Current Branch: "${current_branch}

if [ -z "${current_branch}" ] || [ "${current_branch}" = " " ]; then
	# this should be a RARE condition, but it is just in case...
	echo "Appears to not be a git respository"
	rm -r *
	cd ../
	git clone -o origin ssh://git@10.0.2.160/git/adidas-shoes.git adidas-shoes
	cd "/adidas-shoes"
fi


# check for any changes and stash them
if { ! __parse_git_status clean; }; then
	echo
	echo "git status"
	git status
	echo
	echo "There appear to be uncommited changes. Going to stash them, and back this directory up."
	git stash
	changesWereStashed="true"
fi

# back adidas-shoes up for later restoration
cd ../
adidasshoesback_file="/tmp/adidas-shoes-`date +"%m-%d-%Y"`.zip";
rm -rf ${adidasshoesback_file}
zip -q -r ${adidasshoesback_file} "adidas-shoes";

# stop JBoss
jbstopmsg="\[org.jboss.system.server.Server\] Shutdown complete";
jbstartmsg="Server\] JBoss (MX MicroKernel)";
back_file="/tmp/102ear_bak-`date +"%m-%d-%Y"`.zip";
# Issue the stop command to the JBoss instance
echo "Stopping ${instancename} ..."


if [ $thisHostname = "flqap102.finishline.com" ]; then
    service ${instancename} stop >> /dev/null
else
	echo "JBoss home: ${JBOSS_HOME}"
	"${JBOSS_HOME}shutdown.sh" -s jnp://localhost:1299 >> /dev/null&
fi


#Check the logs for the stop string
echo -n "Waiting for ${instancename} to stop ... "
down="1";
while [ ${down} != 0 ]; do
        if [ $(grep -c "${jbstopmsg}" ${JBOSS_LOG_FILE}) -gt 0 ]; then
                echo "${instancename} halted";
                down="0";
        fi
        sleep 1;
done

echo "${instancename} instance stopped."


# backup the old ear
cd /home/pjc/Development/opt/jboss-4.0.5.GA/server/"${instancename}"/deploy
echo "Creating ear backup zip file in ${back_file}";
rm -rf ${back_file}
zip -q -r ${back_file} finishline.ear/


# cp the ear into place
ear_path="/home/pjc/Development/opt/jboss-4.0.5.GA/server/${instancename}/deploy/finishline.ear"
echo "Removing old ear directory at ${ear_path}";
rm -rf ${ear_path};
echo "Extracting new ear at ${ear_path}";
cd /home/pjc/Development/opt/jboss-4.0.5.GA/server/${instancename}/deploy
unzip -q /tmp/finishline.ear.102.zip
echo "Changing ownership of the ear directory";
#chown -R dynuser:dynuser ${ear_path}
chown -R csc:csc ${ear_path}

# restore adidas-shoes from the temporary copy
# cd into the adidas-shoes directory
cd "/adidas-shoes"

# make note of what branch is currently checked out
current_branch=$(__parse_git_branch)

echo "Current Branch: "${current_branch};

if [ -z "${current_branch}" ] || [ "${current_branch}" = " " ]; then
	echo "Appears to not be a git respository";
	cd "../"
	rm -rf adidas-shoes/*
	git clone -o origin ssh://git@10.0.2.160/git/adidas-shoes.git adidas-shoes
	cd "/adidas-shoes"
fi

# git checkout <whatever branch you had checked out>
git checkout $current_branch

git status

cd ../
unzip -q -o ${adidasshoesback_file}

cd "/adidas-shoes"

if [ "${changesWereStashed}" = "true" ]; then
	echo "there were changes stashed";
	git status
	echo "";
	echo "Going to pop the stash...";
	git stash pop --quiet
	echo "";
	echo git status
fi

echo "";
echo "";
echo "";
echo "Going to try starting JBoss...";
echo "";

# restart the JBoss instance
if [ $thisHostname = "flqap102.finishline.com" ]; then
	echo "Starting ${instancename}";
	service ${instancename} start >> /dev/null
else
	"${JBOSS_HOME}run.sh" --configuration=${instancename} -b localhost >> /dev/null&
fi


sleep 20;


echo "Waiting for ${instancename} to start ... ";
up="1";
tries="0";
while [ ${up} != 0 ]; do
	echo  "try number: ${tries} ...waiting for ${instancename} to start ... ";

	if [ $(grep -c "${jbstartmsg}" ${JBOSS_LOG_FILE}) -gt 0 ]; then
		if [ $? == 0 ]; then
       		echo "${instancename} started";
       	    up="0";
		fi
	fi
	sleep 10;
	if [ $thisHostname = "flqap102.finishline.com" ]; then
		echo "";
	else

		(( tries++ ))

		if [ $tries > 16 ]; then
			echo "we've reached 10 tries, forcing up to 0 to give up...";
			up="0";
		else
			echo "..trying again...";
		fi
	fi

done


# Give the server a minute to get settled.
echo "Waiting for one minute to let the server settle down. Stand by ...";
sleep 30
echo "30 seconds to go..."
sleep 20
echo "10 seconds left..."
sleep 10
echo "Build for ${instancename} (fake!) complete. Proceed to the next server.";
#rm -rf /tmp/finishline.ear.FL_QA.zip
echo "Deploy Complete";
