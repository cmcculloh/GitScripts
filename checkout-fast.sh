#!/bin/bash
# checkout
# checks out a git branch


echo ${H1}
echo "####################################################################################"
echo "Checking out branch ${COL_CYAN}$1${H1} for media"
echo "####################################################################################"
echo ${X}
eval "cd ${media_path}"
git checkout master
eval "${gitscripts_path}checkout.sh $1";



echo ${H1}
echo "####################################################################################"
echo "Checking out branch ${COL_CYAN}$1${H1} for finishline"
echo "####################################################################################"
echo ${X}
eval "cd ${finishline_path}"
git checkout master
eval "${gitscripts_path}checkout.sh $1";


