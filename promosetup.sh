#!/bin/bash

# This script is meant for three things:
#	1. Create a new branch (on both fl and flmedia) with FL's ticket naming convention given a raw string
#	2. Copy the webapp template promo directory to the uri-based directory name along with the files within it
#	3. Copy the media template promo directory similarly to #2
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
echo ${O}${H2HL}${X}
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
echo ${O}${H2HL}${X}

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
		echo "Branch ${B}\`${branch}\`${X} is already checked out."
	else
		$gs_checkout "$branch"
	fi
else
	echo
	echo "Creating new ${COL_GREEN}fl${X} branch: ${branch} ..."
	$gs_new "$branch"
fi

# gather branch names to check against in flmedia path
cd "$media_path"
cb=$(__parse_git_branch)
branches=( `git branch | sed 's/\*//'` )

# if branch already exists, check it out. otherwise, create it.
if __in_array "$branch" "${branches[@]}"; then
	if [ "$cb" = "$branch" ]; then
		echo "Branch ${B}\`${branch}\`${X} is already checked out."
	else
		$gs_checkout "$branch"
	fi
else
	echo
	echo "Creating new ${COL_GREEN}flmedia${X} branch: ${branch} ..."
	$gs_new "$branch"
fi

echo

# check for existing promo and prompt to delete if it exists
if [ -d "$newpromowebappdir" ]; then

	${Q}"This promo already exists in the app. ${A}Delete${Q} it and continue? (y) n"${X}
	read yn
	if [ -n "$yn" ] && [ "$yn" != "y" ] && [ "$yn" != "Y" ]; then
		echo
		echo "No harm no foul. Aborting..."
		exit 0
	fi

	if rm --recursive "$newpromowebappdir"; then
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

	${Q}"This promo's MEDIA already exists. ${A}Delete${Q} it and continue? (y) n"${X}
	read yn
	if [ -n "$yn" ] && [ "$yn" != "y" ] && [ "$yn" != "Y" ]; then
		echo
		echo "No harm no foul. Aborting..."
		exit 0
	fi

	# try the delete
	if rm --recursive "$newpromomediadir"; then
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
	echo ${E}"failed to copy media template directory${X}."
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
if [ ! -e $curbodyfile ]; then
	echo ${E}"failed."
	echo "${curbodyfile} does not exist!"${X}
	exit 7
fi

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