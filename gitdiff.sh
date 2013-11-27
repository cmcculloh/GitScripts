#!/bin/bash
## /*
#   @usage gitdiff [base-branch-name]
#
#   @description
#   This script is used to get a quick look at all the files that have been added,
#   modified, and/or deleted in the current branch's latest commit and either a
#   specified branch (the first parameter) or the master branch (default).
#   description@
#
#   @notes
#   - If your project does not have a master branch, you will need to pass the first
#   parameter for each use.
#   notes@
#
#   @examples
#   1) gitdiff stage      # Shows file changes between the stage branch and HEAD
#   examples@
#
#   @dependencies
#   functions/5000.branch_exists.sh
#   dependencies@
#
#   @file gitdiff.sh
## */
$loadfuncs

__set_remote

echo
branch="master"
[ -n "$_remote" ] && branch="${_remote}/master"
if [ -n "$1" ]; then
    case "$1" in
        -m)
            showModified=true
            [ -n "$2" ] && branch="$2";;

        -a)
            showAll=true
            [ -n "$2" ] && branch="$2";;

        *)
            branch=$1;;
    esac
fi

# make sure branch exists
if ! __branch_exists "$branch"; then
    # maybe the user passed a hash instead of a branch?
    if ! git log -1 --oneline "$branch" &>/dev/null; then
        echo ${E}"  Branch (or hash) \`$branch\` does not exist! Aborting...  "${X}
        exit 1
    fi
fi

# get 7 digit shortened hash for each commit
hashFrom=$(git rev-parse --short $branch)
hashTo=$(git rev-parse --short HEAD)
hashes="${hashFrom}..${hashTo}"
[ "$hashFrom" == "$hashTo" ] && hashesSame=true || hashesSame=

# Based on options passed to this script, figure out what the diff hashes should be
if [ $showModified ]; then
    hashes="$hashTo"
elif [ $showAll ]; then
    hashes="$hashFrom"
fi

# tell us if we have two hashes for the specs
grep -q '\.' <<< "$hashes" && hasRange=true || hasRange=

echo ${O}${H2HL}
if [ ! $hashesSame ] && [ $hasRange ]; then
    echo "$ git --no-pager log --oneline ${hashes}"
    git --no-pager log --oneline $hashes

    echo
    echo
fi
echo "$ git diff --name-status ${hashes}"

if [ "$WINDOWS" == "true" ]; then
    git diff --name-status $hashes
else
    while read STATUS ADDR
    do
        echo "  # $ADDR  ($STATUS)"
    done  < <(git diff --name-status ${hashes})
fi


echo
echo "git diff -w ${hashes}"
echo ${H2HL}${X}

# only need to ask to do a diff if there ARE differences.
if [ -n "$(git diff --name-status $hashes)" ]; then
    echo
    echo ${Q}"Do diff? y (n)"${X}
    read yn
    if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
        git diff -w $hashes
    fi
fi
