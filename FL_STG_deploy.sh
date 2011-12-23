#!/bin/bash

# earDeploy.sh - 20081106 - samuel.kesterson@verizonbusiness.com
# 
# This script is used to deploy a full ear release on www.finishline.com

vms="03finishline";
hn=`hostname -s`;
jbstopmsg="\[org.jboss.system.server.Server\] Shutdown complete";
jbstartmsg="Server\] JBoss (MX MicroKernel)";
back_file="/tmp/flstgear_bak-`date +"%m-%d-%Y"`.zip";

# Issue the start command to all of the instances first. It's faster.
for vm in ${vms}; do
	echo "Stopping ${vm} ..."
        service ${vm} stop >> /dev/null
done

#Check the logs for the stop string
for vm in ${vms}; do
        echo -n "Waiting for ${vm} to stop ... "
        down="1";
        while [ ${down} != 0 ]; do
                if [ $(grep -c "${jbstopmsg}" /opt/jboss/server/${vm}/log/server.log) -gt 0 ]; then
                        echo "${vm} halted";
                        down="0";
                fi
                sleep 1;
        done
done

echo "All instances stopped."

cd /opt/jboss/server/03finishline/deploy 
echo "Creating ear backup zip file in ${back_file}";
rm -rf ${back_file}
zip -q -r ${back_file} finishline.ear/

# Do the actual deploy
for vm in ${vms}; do
        ear_path="/opt/jboss/server/${vm}/deploy/finishline.ear"
        echo "Removing old ear directory at ${ear_path}";
        rm -rf ${ear_path};
        echo "Extracting new ear at ${ear_path}";
        cd /opt/jboss/server/${vm}/deploy
        unzip -q /tmp/finishline.ear.FL_STG.zip
        echo "Changing ownership of the ear directory"
        chown -R dynuser:dynuser ${ear_path}
done

# Start them all
for vm in ${vms}; do
	echo "Starting ${vm}";
        service ${vm} start >> /dev/null
done

#Check the logs
for vm in ${vms}; do
	echo -n "Waiting for ${vm} to start ... ";
        up="1";
        while [ ${up} != 0 ]; do
                if [ $(grep -c "${jbstartmsg}" /opt/jboss/server/${vm}/log/server.log) -gt 0 ]; then
        	        if [ $? == 0 ]; then
               	        	echo "${vm} started";
               	        	up="0";
                	fi
		fi
                sleep 1;
        done
done

# Give the server a minute to get settled.
echo "Waiting for one minute to let the server settle down. Stand by ..."
sleep 60;
echo "Build for ${hn} complete. Proceed to the next server."
#rm -rf /tmp/finishline.ear.FL_QA.zip
echo "Deploy Complete"
