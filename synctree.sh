#!/bin/bash
## /* @alias synctree
#	@usage synctree <option> <path|name>
#
#	@description
#	For those not using any software to sync FL projects with the JBoss .war archives,
#	this script allows a user to specify which paths and/or files to sync. Currently,
#	only single files/paths can be synced. To sync multiple files/paths at in a single
#	batch process, @see syncmywork.
#	description@
#
#	@options
#	-a	Sync files within the web-app.war archives. File path is relative to .com/store/
#
#	-m	Sync files in the media.war archives. File path is relative to .com/media/
#
#	-p	Sync a promo. If this option is given, the promo uri must follow. The following
#		files/paths will be synced given a promo with uri: promo-uri
#			global/promos/promo-uri/
#			global/promos/promo-uri.jsp
#			landing-pages/promo-uri/
#	options@
#
#	@notes
#	- If a path includes spaces, unexpected behavior may occur. Be sure to enclose the path
#	in quotes to be as safe as possible.
#	- Currently, files are only copied into the JBoss war archive. To be completely safe for
#	complex projects, you should run a full build.
#	notes@
#
#	@examples
#	1) synctree -p college-sports-apparel
#		#syncs the college-sports apparel
#	examples@
#
#	@dependencies
#	gitscripts/path/to/file
#	dependencies@
## */
$loadfuncs


if [ -z "$1" ]; then
	echo "Must provide sync keyword!"
	exit 1
fi

source /d/workspaces/helios_workspace/myscripts/vars.sh


case "$1" in
	"-a")
		# user is syncing a directory/file from the webapp folder into the webapp war
		if [ -n "$2" ]; then
			appPath="${webappdir}/$2"
			if [ -e "${appPath}" ]; then
				export warPath="${jbosswebappwar}/$2"

				# if a directory is specified, some extra processing is required
				if [ -d "${appPath}" ]; then
					warPath=`echo $warPath | awk -f $awkscriptsdir/dirname.awk`
				fi

				echo -n "Syncing file(s) ($2  ->  ${warPath})..."
				cp -r "${appPath}" "${warPath}"
				echo "done."
			else
				echo "File/folder at ${appPath} does not exist!"
				exit 3
			fi
		else
			echo "You must specify a file/folder relative to web-app.war/ to sync!"
			exit 2
		fi
		;;


	"-m")
		# user is syncing a directory/file from the media folder into the media war
		if [ -n "$2" ]; then
			appPath="${mediadir}/$2"
			if [ -e "${appPath}" ]; then
				export mediaPath="${jbossmediawar}/$2"

				# if a directory is specified, some extra processing is required
				if [ -d "${appPath}" ]; then
					mediaPath=`echo $mediaPath | awk -f $awkscriptsdir/dirname.awk`
				fi

				echo -n "Syncing media ($2  ->  ${mediaPath})..."
				cp -r "${appPath}" "${mediaPath}"
				echo "done."
			else
				echo "File/folder at ${appPath} does not exist!"
				exit 3
			fi
		else
			echo "You must specify a media file/folder relative to finishline_media/media/ to sync!"
			exit 2
		fi
		;;


	"-p")
		# user can specify a single promo
		if [ -n "$2" ]; then
			promo=$2

			# check for promo and promo media, syncing if they exist
			if [ -e "${promosdir}/${promo}" ]; then
				sync=1
				src="${promosdir}/${promo}"
				srcjsp="${promosdir}/${promo}.jsp"
				dest="${jbosswebappwar}/global/promos"
				destjsp="${jbosswebappwar}/global/promos/${promo}.jsp"
				echo
				echo "Syncing promo: $promo ..."
				echo "    sources: $src"
				echo "             $srcjsp"
				echo "    dest:    $dest"
				echo "             $destjsp"
				cp -r $src $dest
				cp -r $srcjsp $destjsp
			fi
			if [ -e "${mediadir}/landing-pages/${promo}" ]; then
				sync=1
				src="${mediadir}/landing-pages/${promo}"
				dest="${jbossmediawar}/landing-pages"
				echo
				echo "Syncing landing page media: $promo ..."
				echo "    source: $src"
				echo "    dest:   $dest"
				cp -r $src $dest
			fi
			if [ -e "${mediadir}/promos/${promo}" ]; then
				sync=1
				src="${mediadir}/promos/${promo}"
				dest="${jbossmediawar}/promos"
				echo
				echo "Syncing promo media: $promo ..."
				echo "    source: $src"
				echo "    dest:   $dest"
				cp -r $src $dest
			fi

			if [ "$sync" != "1" ]; then
				echo "No promo or promo media found for promo '${promo}'."
			fi
		else
			echo "Syncing all promos..."
			cp -r "${promosdir}" "${jbosswebappwar}/global"
			echo "Syncing 'landing-pages' media..."
			cp -r "${mediadir}/landing-pages" $jbossmediawar
			echo "Syncing 'promos' media..."
			cp -r "${mediadir}/promos" $jbossmediawar
		fi
		;;


	*)
		echo "You must specify an option (-p, -m)."
esac