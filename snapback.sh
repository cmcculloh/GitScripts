#!/bin/bash
# merge
# merges one git branch into another


TEXT_BRIGHT=$'\033[1m'
TEXT_DIM=$'\033[2m'
TEXT_NORM=$'\033[0m'
COL_RED=$'\033[31m'
COL_GREEN=$'\033[32m'
COL_VIOLET=$'\033[34m'
COL_YELLOW=$'\033[33m'
COL_MAG=$'\033[35m'
COL_CYAN=$'\033[36m'
COL_WHITE=$'\033[37m'
COL_NORM=$'\033[39m'

function __parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

currentBranch="$(__parse_git_branch)"

echo "##########################################"
echo "Shoot from ${COL_CYAN}${currentBranch}${COL_NORM} into ${COL_CYAN}master${COL_NORM} and back"
echo "##########################################"
echo
echo




echo
echo
echo "First, we check out the ${COL_CYAN}master${COL_NORM} branch"
${gitscripts_path}checkout-fast.sh master
result=$?

if [ $result -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "git checkout master failed"
	exit -1
elif [ $result -eq 255 ]
	then
	echo "Checking out the branch ${COL_CYAN}master${COL_NORM} was unsuccessful, aborting snap attempt..."
	exit -1
fi




touchpath="${finishline_path}modules/base/j2ee-apps/base/web-app.war"


find "$touchpath" -type f -print0 | xargs -0 touch  -m -d '1974-01-05 13:31:00'

echo
echo

echo "Now we will check out the ${currentBranch} branch"
${gitscripts_path}checkout-fast.sh ${currentBranch}
result=$?

if [ $result -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "checkout of branch ${currentBranch} failed"
	exit -1
elif [ $result -eq 255 ]
	then
	echo "Checking out the branch ${currentBranch} was unsuccessful, aborting snap attempt..."
	exit -1
fi



function __parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

currentBranch="$(__parse_git_branch)"


NOW=$(date +"%Y-%m-%d")

# min


targetpath="${builds_path}build/front-end/exports/staging/code-exports/"
zippath="${builds_path}build/front-end/zips/staging/"

echo "Going to wipeout export files in  ${COL_YELLOW}${target_path}${COL_NORM}"
rm -f -r "${targetpath}"


echo "Going to export files that are different in ${COL_CYAN}${currentBranch}${COL_NORM} from ${COL_CYAN}master${COL_NORM}"
echo "...to ${COL_YELLOW}${targetpath}${COL_NORM}"

${gitscripts_path}cpafter.sh -f -a $NOW -s "${touchpath}" -t "${targetpath}"

targetpathqa="${builds_path}build/front-end/exports/qa/code-exports/"
targetpathdev="${builds_path}build/front-end/exports/dev/code-exports/"

rm -f -r "${targetpathqa}"
rm -f -r "${targetpathdev}"

echo mkdir "${targetpathqa}"
echo mkdir "${targetpathdev}"



cp -fr "${targetpath}" "${targetpathqa}"
cp -fr "${targetpath}" "${targetpathdev}"


rm -f -r "${targetpathqa}assets/"
rm -f -r "${targetpathdev}assets/"


cd "${targetpath}"
pwd
ls -la



cd "${targetpath}assets/"
pwd
ls -la


cd "${targetpath}global/promos/"
pwd
ls -la


#tar  cvf "${zippath}$NOW.tar"  "${targetpath}"
#gzip "${zippath}$NOW.tar"
#



cd "${finishline_path}"
pwd

git status



