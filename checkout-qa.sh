#!/bin/bash
# checkout
# checks out a git branch




echo


`cd ${media_path}`

git fetch --all --prune
git checkout master
git branch -D qa
git checkout qa



`cd ${finishline_path}`

git fetch --all --prune
git checkout master
git branch -D qa
git checkout qa


