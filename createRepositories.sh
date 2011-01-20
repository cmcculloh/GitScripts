# To create all of the required finishline repositories, copy this file into the workspace folder you want them created under
# by default, this should be /d/workspaces/helios_workspace/ and then enter the following command:

# source createRepo.sh

git clone -o origin ssh://git@flgit.finishline.com/git/flgitscripts.git gitscripts
git clone -o origin ssh://git@flgit.finishline.com/git/fl_deploy_scripts.git deploys
git clone -o origin ssh://git@flgit.finishline.com/git/finishline_build.git builds
git clone -o fl ssh://git@flgit.finishline.com/git/finishline.git finishline
git clone -o flmedia ssh://git@flgit.finishline.com/git/finishline_media.git finishline_media
git clone -o origin ssh://git@flgit.finishline.com/git/image_scripts.git image_scripts

git config --global color.status auto
git config --global color.branch auto

#git config --global user.name "Your Name Here"
#git config --global user.email "Your Email Here"