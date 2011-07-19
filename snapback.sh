#!/bin/bash
# merge
# merges one git branch into another




#########################################################################################################################
#custom __parse_git_branch function
#########################################################################################################################
function __parse_git_branch {
 git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

cd ${finishline_path}
startingBranch="$(__parse_git_branch)"



echo ${H1}
echo "####################################################################################"
echo "SNAPBACK: shoot from ${COL_CYAN}${startingBranch}${H1} to ${COL_CYAN}master${H1}, take a snapshot, export diffs    "
echo "####################################################################################"
echo ${X}





echo
echo
echo "First, we check out the ${COL_CYAN}master${COL_NORM} branch"
${gitscripts_path}checkout-fast.sh master
result=$?

if [ $result -lt 0 ]
	then
	echo ${E}"####################################################################################"
	echo "Error: could not check out ${COL_CYAN}master${COL_NORM}, aborting snap attempt      "
	echo "####################################################################################"${X}
	echo ${O}
	echo "------------------------------------------------------------------------------------"
	echo "# git status"
	git status
	echo ${X}
	exit -1
elif [ $result -eq 255 ]
	then
	echo ${E}"####################################################################################"
	echo "Error: could not check out ${COL_CYAN}master${COL_NORM}, aborting snap attempt      "
	echo "####################################################################################"${X}
	echo ${O}
	echo "------------------------------------------------------------------------------------"
	echo "# git status"
	git status
	echo ${X}
	exit -1
fi

touchpath="${finishline_path}modules/base/j2ee-apps/base/web-app.war"


find "$touchpath" -type f -print0 | xargs -0 touch  -m -d '1974-01-05 13:31:00'



cd ${media_path}
startingBranchMedia="$(__parse_git_branch)"

echo
echo
echo "Now we will check out the ${COL_CYAN}master${COL_NORM} branch for media"
${gitscripts_path}checkout-fast.sh master
result=$?

if [ $result -lt 0 ]
	then
	echo ${E}"####################################################################################"
	echo "Error: could not check out ${COL_CYAN}master${COL_NORM}, aborting snap attempt      "
	echo "####################################################################################"${X}
	echo ${O}
	echo "------------------------------------------------------------------------------------"
	echo "# git status"
	git status
	echo ${X}
	exit -1
elif [ $result -eq 255 ]
	then
	echo ${E}"####################################################################################"
	echo "Error: could not check out ${COL_CYAN}master${COL_NORM}, aborting snap attempt      "
	echo "####################################################################################"${X}
	echo ${O}
	echo "------------------------------------------------------------------------------------"
	echo "# git status"
	git status
	echo ${X}
	exit -1
fi

touchpathMedia="${media_path}media"


find "$touchpathMedia" -type f -print0 | xargs -0 touch  -m -d '1974-01-05 13:31:00'




echo
echo




echo "Now we will check out the ${startingBranch} branch"
cd ${finishline_path}
${gitscripts_path}checkout-fast.sh ${startingBranch}
result=$?

if [ $result -lt 0 ]
	then
	echo ${E}"####################################################################################"
	echo "Error: could not check out ${COL_CYAN}${startingBranch}${COL_NORM}, aborting snap attempt "
	echo "####################################################################################"${X}
	echo ${O}
	echo "------------------------------------------------------------------------------------"
	echo "# git status"
	git status
	echo ${X}
	exit -1
elif [ $result -eq 255 ]
	then
	echo ${E}"####################################################################################"
	echo "Error: could not check out ${COL_CYAN}${startingBranch}${COL_NORM}, aborting snap attempt "
	echo "####################################################################################"${X}
	echo ${O}
	echo "------------------------------------------------------------------------------------"
	echo "# git status"
	git status
	echo ${X}
	exit -1
fi




echo "Now we will check out the ${startingBranchMedia} branch for media"
cd ${media_path}
${gitscripts_path}checkout-fast.sh ${startingBranchMedia}
result=$?

if [ $result -lt 0 ]
	then
	echo ${E}"####################################################################################"
	echo "Error: could not check out ${COL_CYAN}${startingBranchMedia}${COL_NORM}, aborting snap attempt "
	echo "####################################################################################"${X}
	echo ${O}
	echo "------------------------------------------------------------------------------------"
	echo "# git status"
	git status
	echo ${X}
	exit -1
elif [ $result -eq 255 ]
	then
	echo ${E}"####################################################################################"
	echo "Error: could not check out ${COL_CYAN}${startingBranchMedia}${COL_NORM}, aborting snap attempt "
	echo "####################################################################################"${X}
	echo ${O}
	echo "------------------------------------------------------------------------------------"
	echo "# git status"
	git status
	echo ${X}
	exit -1
fi




NOW=$(date +"%Y-%m-%d")

# min


targetpath="${builds_path}build/front-end/exports/staging/code-exports/"
targetpathMedia="${builds_path}build/front-end/exports/staging/media-exports/"
zippath="${builds_path}build/front-end/zips/staging/"

echo "Going to wipeout export files in  ${COL_YELLOW}${target_path}${COL_NORM}"
rm -f -r "${targetpath}"

echo "Going to wipeout export files in  ${COL_YELLOW}${target_pathMedia}${COL_NORM}"
rm -f -r "${targetpathMedia}"


echo "Going to export files that are different in ${COL_CYAN}${startingBranch}${COL_NORM} from ${COL_CYAN}master${COL_NORM}"
echo "...to ${COL_YELLOW}${targetpath}${COL_NORM}"

${gitscripts_path}cpafter.sh -f -a $NOW -s "${touchpath}" -t "${targetpath}"



echo "Going to export files that are different in ${COL_CYAN}${startingBranchMedia}${COL_NORM} from ${COL_CYAN}master${COL_NORM}"
echo "...to ${COL_YELLOW}${targetpathMedia}${COL_NORM}"

${gitscripts_path}cpafter.sh -f -a $NOW -s "${touchpathMedia}" -t "${targetpathMedia}"


targetpathqa="${builds_path}build/front-end/exports/qa/code-exports/"
targetpathdev="${builds_path}build/front-end/exports/dev/code-exports/"

targetpathqaMedia="${builds_path}build/front-end/exports/qa/media-exports/"
targetpathdevMedia="${builds_path}build/front-end/exports/dev/media-exports/"

rm -f -r "${targetpathqa}"
rm -f -r "${targetpathdev}"

rm -f -r "${targetpathqaMedia}"
rm -f -r "${targetpathdevMedia}"

echo mkdir "${targetpathqa}"
echo mkdir "${targetpathdev}"


echo mkdir "${targetpathqaMedia}"
echo mkdir "${targetpathdevMedia}"



cp -fr "${targetpath}" "${targetpathqa}"
cp -fr "${targetpath}" "${targetpathdev}"



cp -fr "${targetpathMedia}" "${targetpathqaMedia}"
cp -fr "${targetpathMedia}" "${targetpathdevMedia}"


rm -f -r "${targetpathqa}assets/"
rm -f -r "${targetpathdev}assets/"


cd "${targetpath}"
pwd
ls -RC



cd "${targetpath}assets/"
pwd
ls -RC


cd "${targetpath}global/promos/"
pwd
ls -RC


cd "${targetpathMedia}"
pwd
ls -RC





cd ${media_path}
pwd



#tar  cvf "${zippath}$NOW.tar"  "${targetpath}"
#gzip "${zippath}$NOW.tar"
#

echo ${O}
echo "media: ------------------------------------------------------------------------------------"
echo "# git status"
git status
echo ${X}

exit 0



cd ${finishline_path}
pwd



echo ${O}
echo "------------------------------------------------------------------------------------"
echo "# git status"
git status
echo ${X}

exit 0

#	
#	
#	echo ${O}
#	echo "------------------------------------------------------------------------------------"
#	echo "# git status"
#	git status
#	echo ${X}
#	
#	

#	echo ${I}"####################################################################################"
#	echo "Upload to dev, qa, and staging? ${COL_CYAN}(y)${I} n "
#	echo "####################################################################################"${X}
#	read YorN
#	if [ "$YorN" = "y" ] || [ "$YorN" = "Y" ] || [ "$YorN" = "" ]
#		then
#		echo ""
#		echo "builds_path; // " ${builds_path}
#		echo ""
#		echo ${O}"------------------------------------------------------------------------------------"
#		echo "Uplading..."
#		echo "------------------------------------------------------------------------------------"
#		ant ${ANT_ARGS} upload-all-exports -buildfile ${builds_path}"all-remotes.build.xml" ;
#		echo "------------------------------------------------------------------------------------"${X}
#	fi
#	
#	
#	echo ${I}"####################################################################################"
#	echo "Zip code and media exports for handoff? ${COL_CYAN}(y)${I} n "
#	echo "####################################################################################"${X}
#	read YorN
#	if [ "$YorN" = "y" ] || [ "$YorN" = "Y" ] || [ "$YorN" = "" ]
#		then
#		echo ${O}"------------------------------------------------------------------------------------"
#		echo "Zipping exports now..."
#		echo "------------------------------------------------------------------------------------"
#		ant ${ANT_ARGS} promos-zip-up-exports -buildfile ${builds_path}"staging-front-end.build.xml" ;
#		echo "------------------------------------------------------------------------------------"${X}
#	fi
#	



