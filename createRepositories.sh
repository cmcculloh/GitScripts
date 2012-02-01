#!/bin/bash

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

echo "This will clone all of our repositories."
echo "The default location is:"
echo "    /d/workspaces/helios_workspace/"
echo "You have chosen: "
echo "    $location"
echo
echo "When cloning, currently existing repos will not"
echo "be overwritten, however, they will throw \"fatal\""
echo "errors. Please ignore these \"errors\""
echo "----------------------------------------------------"
echo

echo "Add remote hosts to hosts file? (y) n"
echo "If this is the first time git was configured on this"
echo "machine, you should probably answer y."
read doHosts
echo
if [ -z $doHosts ] || [ $doHosts = "y" ]
	then
	remotehost1="10.0.2.160	flgit.finishline.com"
	remotehost2="10.0.2.160	flbuild.finishline.com"
	echo >> /c/WINDOWS/system32/drivers/etc/hosts
	echo -n $remotehost1 >> /c/WINDOWS/system32/drivers/etc/hosts
	echo >> /c/WINDOWS/system32/drivers/etc/hosts
	echo -n $remotehost2 >> /c/WINDOWS/system32/drivers/etc/hosts
	echo "added remote hosts to hosts file..."
fi
	
cd $location

echo "Clone all workspace repositories here? ($location) "
echo "nothing will be overwritten. (y) n"
read createRepos
echo
if [ -z $createRepos ] || [ $createRepos = "y" ]
	then
	git clone -o origin ssh://git@flgit.finishline.com/git/flgitscripts.git flgitscripts
	echo "cloned gitscripts"
	git clone -o origin ssh://git@flgit.finishline.com/git/fl_deploy_scripts.git deploys
	echo "cloned deploys"
	git clone -o origin ssh://git@flgit.finishline.com/git/finishline_build.git builds
	echo "cloned builds"
	git clone -o fl ssh://git@flgit.finishline.com/git/finishline.git finishline
	echo "cloned finishline"
	git clone -o flmedia ssh://git@flgit.finishline.com/git/finishline_media.git finishline_media
	echo "cloned finishline_media"
	git clone -o origin ssh://git@flgit.finishline.com/git/image_scripts.git image_scripts
	echo "cloned image_scripts"
	git clone -o origin ssh://git@flgit.finishline.com/git/promo_editor.git promo_editor
	echo "cloned promo_editor"
	git clone -o origin ssh://git@flgit.finishline.com/git/finishline_csr.git finishline_csr
	echo "cloned finishline_csr"
	git clone -o origin ssh://git@flgit.finishline.com/git/naturaldocs.git naturaldocs
	echo "cloned naturaldocs"
	git clone -o origin ssh://git@flgit.finishline.com/git/qa.git qa
	echo "cloned qa"
	git clone -o origin ssh://git@flgit.finishline.com/git/run.git MultiSiteStore
	echo "cloned run.com -> MultiSiteStore"
	git clone -o origin ssh://git@flgit.finishline.com/git/run_utilities.git run_utilities
	echo "cloned run.com utilities -> run_utilities"
	git clone -o origin ssh://git@flgit.finishline.com/git/run_endeca.git run_endeca
	echo "cloned run.com endeca -> run_endeca"
fi

echo
echo "The etc project is available for cloning as well"
echo "(1) Do not clone etc"
echo " 2  Clone etc to D:/"
echo " 3  Clone etc to the current directory"
echo " 4  Clone etc to the directory of my choice"
read decision
echo
if [ -z $decision ] || [ $decision -eq 1 ]
	then
	echo
	#do nothing
elif [ $decision -eq 2 ]
    then
	cd /d/
	git clone -o origin ssh://git@flgit.finishline.com/git/finishline_etc.git etc
	echo "cloned etc"
	cd etc
	git config core.autocrlf input
	cd $location
elif [ $decision -eq 3 ]
	then
	git clone -o origin ssh://git@flgit.finishline.com/git/finishline_etc.git etc
	echo "cloned etc"
	git config core.autocrlf input
elif [ $decision -eq 4 ]
	then
	echo "please enter the directory you would like to clone the etc project to"
	read directory
	if [ $directory -n ]
		then
		cd $directory
		git clone -o origin ssh://git@flgit.finishline.com/git/finishline_etc.git etc
		echo "cloned etc"
		git config core.autocrlf input
	else
		echo "you did not enter a directory, aborting cloning of etc"
	fi
fi
echo

git config --global color.status auto
git config --global color.branch auto
git config --global color.diff auto
git config --global color.ui auto

echo "Configure for windows? (y) n"
read configure
if [ -n "$configure" ] || [ "$configure" = "y" ]
	then
	git config --global core.autocrlf true
	git config --global core.safecrlf true
fi

echo "set global git config options"

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

echo "done!"

cd $current_location
