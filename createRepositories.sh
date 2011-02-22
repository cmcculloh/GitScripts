#!/bin/sh

current_location=$(pwd)

location="/d/workspaces/helios_workspace/"
if [ -n $1 ] && [ "$1" != " " ] && [ "$1" != "" ]
	then
	echo $1
	location=$1
fi

# There is an alias set up to call this file with, use it like so:

# createrepositories /d/workspaces/helios_workspace/ "Christopher McCulloh" cmcculloh@finishline.com

# (replacing "/d/workspaces/helios_workspace/" with the path you want the workspaces created in)

# You can run this script as many times in the same location as you want. If you already have one
# or more of the repositories set up there (with the same naming scheme) it will just skip those

cd $location

git clone -o origin ssh://git@flgit.finishline.com/git/flgitscripts.git gitscripts
git clone -o origin ssh://git@flgit.finishline.com/git/fl_deploy_scripts.git deploys
git clone -o origin ssh://git@flgit.finishline.com/git/finishline_build.git builds
git clone -o fl ssh://git@flgit.finishline.com/git/finishline.git finishline
git clone -o flmedia ssh://git@flgit.finishline.com/git/finishline_media.git finishline_media
git clone -o origin ssh://git@flgit.finishline.com/git/image_scripts.git image_scripts
git clone -o origin ssh://git@flgit.finishline.com/git/promo_editor.git promo_editor
git clone -o origin ssh://git@flgit.finishline.com/git/finishline_csr.git finishline_csr
git clone -o origin ssh://git@flgit.finishline.com/git/naturaldocs.git naturaldocs
git clone -o origin ssh://git@flgit.finishline.com/git/finishline_etc.git etc

git config --global color.status auto
git config --global color.branch auto

if [ -n "$2" ] && [ "$2" != " " ] && [ "$2" != "" ]
	then
	echo "$2"
	git config --global user.name "$2"
	
	if [ -n "$3" ] && [ "$3" != " " ] && [ "$3" != "" ]
		then
		echo "$3"
		git config --global user.email "$3"
	fi
fi


cd $current_location
