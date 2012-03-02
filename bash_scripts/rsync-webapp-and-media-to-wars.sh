#!/bin/bash
# 
# calling this file via command line can be done with `xall`
#
# however:
# 
# example sublime text 2 build command -- you must manually supply the build commmand the environment paths to use when calling the bash script.
#
# {
# 	"cmd": ["/home/csc/Development/workspaces/ubuntu_galileo_workspace/flgitscripts/bash_scripts/rsync-webapp-and-media-to-wars.sh"],
# 	"shell": true,
# 	"env": {
# 		"webappwar_path": "/home/csc/Development/workspaces/ubuntu_galileo_workspace/finishline/modules/base/j2ee-apps/base/web-app.war/",
# 		"JBOSS_WEBAPPWAR": "/home/csc/Development/opt/jboss-4.0.5.GA/server/finishline/deploy/finishline.ear/web-app.war/",
# 		"mediaActuallyUseful_path": "/home/csc/Development/workspaces/ubuntu_galileo_workspace/finishline_media/media/",
# 		"JBOSS_MEDIAWAR": "/home/csc/Development/opt/jboss-4.0.5.GA/server/finishline/deploy/media.war/"
# 	}
# }

rsync -rci  --exclude='.git*' --progress $webappwar_path* $JBOSS_WEBAPPWAR; rsync -rci --progress $mediaActuallyUseful_path* $JBOSS_MEDIAWAR;

