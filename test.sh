#!/bin/bash

branch=$(__parse_git_branch)
git branch -r -v --abbrev=7 | grep "$(__parse_git_branch)" | awk '{ gsub(/^.+?[[:blank:]]+/,""); print; }' | cut -b 7



exit