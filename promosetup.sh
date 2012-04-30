#!/bin/bash
## /*
#	@usage promosetup
#
#	@description
#	For most landing pages, the same process is followed. This script follows
#	that process:
#
#		1.) Collect data about the landing page. This includes the ticket
#		    number and subject, the relative uri to store/global/promos,
#		    and the promo HTML's title, meta description, and meta keywords
#		    attributes.
#		2.) Create Git branches based on the ticket information on fl and
#		    flmedia if they don't already exist and switch to them for each
#		    project.
#		3.) Use the relative promo uri and the template folders in fl and
#		    flmedia to create the landing page directories/files in:
#		        /global/promos/<uri>
#		        /global/promos/<uri>.jsp
#		        /media/landing-pages/<uri>
#		    If the directories already exist, you will be prompted to delete
#		    them.
#		4.) You will then be prompted to process the HTML for the promo. This
#		    essentially calls @see processpromohtml. Before answering yes,
#		    you must place the creative HTML file in the /store/global/<uri>
#		    directory. This will extract the HTML and CSS and disperse them to
#		    their appropriate locations.
#	description@
#
#	@notes
#	- The templates for the promos use tokens that get replaced with values
#	  set based on input from the user. If these templates don't exist, you will
#	  need to create them based on values in this script (view source).
#	notes@
#
#	@dependencies
#	*processpromohtml.sh
#	awkscripts/fixbranch.awk
#	awkscripts/replacepromotokens.awk
#	*gitscripts/checkout.sh
#	*gitscripts/new.sh
#	gitscripts/functions/1000.parse_git_branch.sh
#	gitscripts/functions/0400.in_array.sh
#	dependencies@
## */
$loadfuncs


# script-specific vars
export templatename="_"
export webapptempdir="${promos_path}${templatename}"
export mediatempdir="${mediaLandingPagesPath}${templatename}"

export gs_new="${gitscripts_path}new.sh"
export gs_checkout="${gitscripts_path}checkout.sh"

# tokens to replace in templates
token="%@%"
titletoken="%title%"
desctoken="%desc%"
kwtoken="%kw%"


# check settings
echo
if [ ! -d "$webapptempdir" ]; then
	echo ${E}"  Webapp template directory does not exist: ${webapptempdir}  "${X}
	exit 1
fi
if [ ! -d "$mediatempdir" ]; then
	echo ${E}"  Media template directory does not exist: ${mediatempdir}  "${X}
fi

echo "The following questions ${COL_RED}require${X} non-empty answers."
echo ${O}${H2HL}${X}
echo ${I}"Enter the branch name (ticket number and description) in formatted "
echo "or unformatted form:"${X}
read rawbranch
if [ -z "${rawbranch}" ]; then
	echo ${E}"  Branch name omitted. Aborting...  "${X}
	exit 1
fi

echo
echo ${I}"Enter the uri (...com/uri-here) (enter to abort):"${X}
read promouri
if [ -z "${promouri}" ]; then
	echo ${E}"  URI omitted. Aborting...  "${X}
	exit 2
fi
echo
echo
echo

echo "The following questions may be left empty, if desired."
echo ${O}${H2HL}${X}
echo ${I}"Enter the promo's <title> tag value:"${X}
read tagtitle

echo
echo ${I}"Enter the promo's <meta> description:"${X}
read tagmetadesc

echo
echo ${I}"Enter the promo's <meta> keywords:"${X}
read tagmetakeywords
echo

# now that we gathered some info, some new vars need to be established...
export newbranchname=$(awk -f "${awkscripts_path}fixbranch.awk" <<< "${rawbranch}")
export newpromowebappdir="${promos_path}${promouri}"
export newpromomediadir="${mediaLandingPagesPath}${promouri}"

#review input
echo
echo

echo ${O}${H2HL}${X}
echo "Promo settings thus far:"
echo ${O}${H2HL}${X}
echo "Branch:           ${B}${newbranchname}"${X}
echo "URI:              ${promouri}"
echo "<title>:          ${tagtitle}"
echo "<meta desc>:      ${tagmetadesc}"
echo "<meta keywords>:  ${tagmetakeywords}"
echo ${O}${H2HL}${X}
echo
echo "Generate promo with these settings? (y) n"
read yesno

if [ -n "$yesno" ] && [ "$yesno" != "y" ] && [ "$yesno" != "Y" ]; then
	echo
	echo "Fair enough. Aborting..."
	exit 1
fi

# easier to type
branch="${newbranchname}"

# gather branch names to check against in fl path
cd "$finishline_path"
cb=$(__parse_git_branch)
branches=( `git branch | sed 's/\*//'` )

# if branch already exists, check it out. otherwise, create it.
if __in_array "$branch" "${branches[@]}"; then
	if [ "$cb" = "$branch" ]; then
		echo "Branch ${B}\`${branch}\`${X} is already checked out in ${COL_GREEN}fl${X}."
	else
		$gs_checkout "$branch"
	fi
else
	echo
	echo "Creating new ${COL_GREEN}fl${X} branch: \`${branch}\` ..."
	$gs_new "$branch"
fi

# gather branch names to check against in flmedia path
cd "$media_path"
cb=$(__parse_git_branch)
branches=( `git branch | sed 's/\*//'` )

# if branch already exists, check it out. otherwise, create it.
if __in_array "$branch" "${branches[@]}"; then
	if [ "$cb" = "$branch" ]; then
		echo "Branch ${B}\`${branch}\`${X} is already checked out in ${COL_GREEN}flmedia${X}."
	else
		$gs_checkout "$branch"
	fi
else
	echo
	echo "Creating new ${COL_GREEN}flmedia${X} branch: \`${branch}\` ..."
	$gs_new "$branch"
fi

echo

# check for existing promo and prompt to delete if it exists
if [ -d "$newpromowebappdir" ]; then

	echo ${Q}"This promo already exists in the app. ${A}Delete${Q} it and continue? (y) n"${X}
	read yn
	if [ -n "$yn" ] && [ "$yn" != "y" ] && [ "$yn" != "Y" ]; then
		echo
		echo "No harm no foul. Aborting..."
		exit 0
	fi

	if rm -R "$newpromowebappdir"; then
		# ...and the jsp...
		[ -s "${newpromowebappdir}.jsp" ] && rm "${newpromowebappdir}.jsp"
		echo ${COL_GREEN}"Delete succeeded!"${X}
	else
		echo ${E}"  Delete failed!  "${X}
		echo
		echo "Continue anyway? (y) n"
		read yn
		if [ -n "$yn" ] && [ "$yn" != "y" ] && [ "$yn" != "Y" ]; then
			echo
			echo "No harm no foul. Aborting..."
			exit 1
		fi
	fi

fi

# check for exisiting promo MEDIA and delete it if it exists.
if [ -d "$newpromomediadir" ]; then

	echo ${Q}"This promo's MEDIA already exists. ${A}Delete${Q} it and continue? (y) n"${X}
	read yn
	if [ -n "$yn" ] && [ "$yn" != "y" ] && [ "$yn" != "Y" ]; then
		echo
		echo "No harm no foul. Aborting..."
		exit 0
	fi

	# try the delete
	if rm -R "$newpromomediadir"; then
		echo ${COL_GREEN}"Delete succeeded!"${X}
	else
		echo ${E}"  Delete failed!  "${X}
		echo
		echo "Continue anyway? (y) n"
		read yn
		if [ -n "$yn" ] && [ "$yn" != "y" ] && [ "$yn" != "Y" ]; then
			echo
			echo "No harm no foul. Aborting..."
			exit 1
		fi
	fi

fi


echo
echo -n "${A}Copying${X} ${COL_GREEN}flmedia${X} ${promouri} directory from template..."
cp -ir "$mediatempdir" "${newpromomediadir}"

# check...
if [ -d "${newpromomediadir}" ]; then
	echo ${COL_GREEN}"done${X}."
else
	echo ${E}"failed to copy media template directory${X}."${X}
fi

echo
echo -n "${A}Copying${X} ${COL_GREEN}fl${X} ${promouri} directory from template..."
cp -ir "$webapptempdir" "${newpromowebappdir}"

# check...
if [ -d "${newpromowebappdir}" ]; then
	echo ${COL_GREEN}"done${X}."
else
	echo ${E}"failed to copy webapp template directory. Cannot continue..."${X}
	exit 6
fi

echo
echo -n "${A}Replacing${X} promo tokens in webapp files..."
indexfile="${newpromowebappdir}/index.jsp"
curbodyfile="${newpromowebappdir}/${token}.index_body.jsp"

# check for index.jsp
if [ ! -e "$indexfile" ]; then
	echo ${E}"failed."
	echo "${indexfile} does not exist!"${X}
	exit 7
fi
# check for _.index_body.jsp
if [ ! -e "$curbodyfile" ]; then
	echo ${E}"failed."
	echo "${curbodyfile} does not exist!"${X}
	exit 7
fi

# replace tokens with values user chose
awk -v token="${token}" -v titletoken="${titletoken}" -v desctoken="${desctoken}" -v kwtoken="${kwtoken}" -f "${awkscripts_path}replacepromotokens.awk" promouri="${promouri}" tagtitle="${tagtitle}" tagmetadesc="${tagmetadesc}" tagmetakeywords="${tagmetakeywords}" "$indexfile" > "$tmp"

echo ${COL_GREEN}"done."${X}
echo
echo -n "${A}Dispersing${X} files..."

mv -i "$indexfile" "${indexfile}.bak"
cp -i "$tmp" "${newpromowebappdir}.jsp"
cp -i "$tmp" "$indexfile"
mv -i "$curbodyfile" "${newpromowebappdir}/${promouri}.index_body.jsp"

if [ ! -s "$indexfile" ] || [ ! -s "${newpromowebappdir}.jsp" ] || [ -e "$curbodyfile" ]; then
	echo ${E}"failed. One or more files did not copy properly."${X}
else
	echo ${COL_GREEN}"done."${X}
	echo
	echo "Successfully copied files to their destinations!"
	echo
	echo ${Q}"Remove template backups? (y) n"${X}
	read yesno
	if [ -z "$yesno" ] || [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
		rm "${indexfile}.bak"
		rm "$tmp"
		echo
		echo "Files removed!"
	fi
fi

echo
echo ${Q}"Would you like to process the promo html? y (n)"${X}
read yesno

if [ "$yesno" = "y" ] || [ "$yesno" = "Y" ]; then
	"${flgitscripts_path}processpromohtml.sh" "${promouri}"
fi

exit 0
