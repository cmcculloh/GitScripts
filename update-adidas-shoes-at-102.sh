#!/bin/bash

source "${flgitscripts_path}refresh_bash_profile.sh"


EARNAME="finishline.ear"
EARZIPPED="finishline.ear.102.zip"
DEPLOYLOCATION=$JBOSS"server/alt_finishline/deploy/"
# run the build, compile the ear
# ant ${ANT_ARGS} clean-build -buildfile ${finishline_path}${myenvironment}.build.xml



# zip the ear up
cd ${DEPLOYLOCATION};
#zip -r ${EARZIPPED} ${EARNAME};


# scp the .ear to 102, temp location
#scp ${EARZIPPED} ccorwin@172.17.2.102:/tmp
cp  ${EARZIPPED} /tmp


#/opt/jboss/server/03finishline/deploy/finishline.ear/web-app.war/global/promos/adidas-shoes/

# ssh into 102 and run a script that does the rest of it


#ssh ccorwin@172.17.2.102 "/deployers/adidas-shoes-bak-and-deploy.sh"
"${$flgitscripts_path}adidas-shoes-bak-and-deploy.sh"

