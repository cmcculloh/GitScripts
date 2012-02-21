# rsync -rc  --exclude='.git*' --progress /home/csc/Development/workspaces/ubuntu_galileo_workspace/finishline/modules/base/j2ee-apps/base/web-app.war/* /home/csc/Development/opt/jboss-4.0.5.GA/server/finishline/deploy/finishline.ear/web-app.war/; rsync -rc --progress /home/csc/Development/workspaces/ubuntu_galileo_workspace/finishline_media/media/* /home/csc/Development/opt/jboss-4.0.5.GA/server/finishline/deploy/media.war/
rsync -rci  --exclude='.git*' --progress $webappwar_path* $JBOSS_WEBAPPWAR; rsync -rci --progress $mediaActuallyUseful_path* $JBOSS_MEDIAWAR;

