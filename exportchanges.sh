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


NOW=$(date +"%m-%d-%Y")

echo ${gitscripts_path}cpafter.sh -vf -a $NOW -s ${finishline_path} -t ${builds_path}build/front-end/exports/staging/code-exports




touchpath="${finishline_path}modules/base/j2ee-apps/base/web-app.war"


rm -r "${builds_path}build/front-end/exports/staging/code-exports/"

${gitscripts_path}cpafter.sh -f -a $NOW -s ${touchpath} -t ${builds_path}build/front-end/exports/staging/code-exports


