# There is an alias set up to call this file with, use it like so:

# createrepositories /d/workspaces/helios_workspace/

# (replacing "/d/workspaces/helios_workspace/" with the path you want the workspaces created in)

# You can run this script as many times in the same location as you want. If you already have one
# or more of the repositories set up there (with the same naming scheme) it will just skip those

cd $1

git clone -o origin ssh://git@flgit.finishline.com/git/flgitscripts.git gitscripts
git clone -o origin ssh://git@flgit.finishline.com/git/fl_deploy_scripts.git deploys
git clone -o origin ssh://git@flgit.finishline.com/git/finishline_build.git builds
git clone -o fl ssh://git@flgit.finishline.com/git/finishline.git finishline
git clone -o flmedia ssh://git@flgit.finishline.com/git/finishline_media.git finishline_media
git clone -o origin ssh://git@flgit.finishline.com/git/image_scripts.git image_scripts
git clone -o origin ssh://git@flgit.finishline.com/git/promo_editor.git promo_editor
git clone -o origin ssh://git@flgit.finishline.com/git/finishline_csr.git finishline_csr

git config --global color.status auto
git config --global color.branch auto

#git config --global user.name "Your Name Here"
#git config --global user.email "Your Email Here"