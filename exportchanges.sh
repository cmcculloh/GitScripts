#!/bin/bash
# merge
# merges one git branch into another





NOW=$(date +"%m-%d-%Y")

echo ${gitscripts_path}cpafter.sh -vf -a $NOW -s ${finishline_path} -t ${builds_path}build/front-end/exports/staging/code-exports




touchpath="${finishline_path}modules/base/j2ee-apps/base/web-app.war"


rm -r "${builds_path}build/front-end/exports/staging/code-exports/"

${gitscripts_path}cpafter.sh -f -a $NOW -s ${touchpath} -t ${builds_path}build/front-end/exports/staging/code-exports


