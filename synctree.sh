#!/bin/bash
## /*
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
#		#syncs the college-sports-apparel promo
#	examples@
#
#	@dependencies
#	gitscripts/functions/0100.bad_usage.sh
#	gitscripts/awk/dirname.awk
#	dependencies@
## */
$loadfuncs


if [ -z "$1" ]; then
	__bad_usage synctree "Must provide sync option AND path!"
	exit 1
fi


case "$1" in
	"-a")
		# user is syncing a directory/file from the webapp folder into the webapp war
		if [ -n "$2" ]; then
			appPath="${webappwar_path}$2"
			if [ -e "${appPath}" ]; then
				export warPath="${JBOSS_WEBAPPWAR}/$2"

				# if a directory is specified, some extra processing is required
				if [ -d "${appPath}" ]; then
					warPath=`echo "$warPath" | awk -f ${awkscripts_path}dirname.awk`
				fi

				echo -n "${A}Syncing${X} file(s) ($2  ->  ${warPath})..."
				cp -r "${appPath}" "${warPath}"
				echo "done."
			else
				echo ${E}"  File/folder at ${appPath} does not exist!  "${X}
				exit 3
			fi
		else
			__bad_usage synctree "You must specify a file/folder relative to web-app.war/ to sync!"
			exit 2
		fi
		;;


	"-m")
		# user is syncing a directory/file from the media folder into the media war
		if [ -n "$2" ]; then
			appPath="${media_path}media/$2"
			if [ -e "${appPath}" ]; then
				export mediaPath="${JBOSS_MEDIAWAR}$2"

				# if a directory is specified, some extra processing is required
				if [ -d "${appPath}" ]; then
					mediaPath=`echo "$mediaPath" | awk -f "${awkscripts_path}"dirname.awk`
				fi

				echo -n "${A}Syncing${X} media ($2  ->  ${mediaPath})..."
				cp -r "${appPath}" "${mediaPath}"
				echo "done."
			else
				echo ${E}"  File/folder at ${appPath} does not exist!  "${X}
				exit 3
			fi
		else
			__bad_usage synctree "You must specify a media file/folder relative to finishline_media/media/ to sync!"
			exit 2
		fi
		;;


	"-p")
		mediadir="${media_path}media/"
		# user can specify a single promo
		if [ -n "$2" ]; then
			promo=$2

			# check for promo and promo media, syncing if they exist
			if [ -e "${promos_path}${promo}" ]; then
				sync=1
				src="${promos_path}${promo}"
				srcjsp="${src}.jsp"
				dest="${JBOSS_WEBAPPWAR}/global/promos"
				destjsp="${dest}/${promo}.jsp"
				echo
				echo "${A}Syncing${X} promo: $promo ..."
				echo "    sources: $src"
				echo "             $srcjsp"
				echo "    dest:    $dest"
				echo "             $destjsp"
				cp -r "$src" "$dest"
				cp -r "$srcjsp" "$destjsp"
			fi
			if [ -e "${mediadir}landing-pages/${promo}" ]; then
				sync=1
				src="${mediadir}landing-pages/${promo}"
				dest="${JBOSS_MEDIAWAR}/landing-pages"
				echo
				echo "${A}Syncing${X} landing page media: $promo ..."
				echo "    source: $src"
				echo "    dest:   $dest"
				cp -r "$src" "$dest"
			fi
			if [ -e "${mediadir}promos/${promo}" ]; then
				sync=1
				src="${mediadir}promos/${promo}"
				dest="${JBOSS_MEDIAWAR}/promos"
				echo
				echo "${A}Syncing${X} promo media: $promo ..."
				echo "    source: $src"
				echo "    dest:   $dest"
				cp -r "$src" "$dest"
			fi

			if [ "$sync" != "1" ]; then
				echo ${E}"  No promo or promo media found for promo '${promo}'.  "${X}
			fi
		else
			echo "${A}Syncing${X} all promos..."
			cp -r "${promos_path}" "${JBOSS_WEBAPPWAR}global"
			echo "${A}Syncing${X} 'landing-pages' media..."
			cp -r "${mediadir}landing-pages" "$JBOSS_MEDIAWAR"
			echo "${A}Syncing${X} 'promos' media..."
			cp -r "${mediadir}promos" "$JBOSS_MEDIAWAR"
		fi
		;;


	*)
		__bad_usage synctree "You must specify an option (-a, -p, -m).";;
esac

exit
