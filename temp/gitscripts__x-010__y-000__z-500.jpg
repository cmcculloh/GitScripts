#!/bin/bash


echo
echo git status
git status
echo


echo "git commit -q -m \"$(__git_ps1) $1\" $2"
git commit -q -m "$(__git_ps1) $1" $2

git diff-tree --stat HEAD

echo


git status



echo
echo

echo "Would you like to push? y (n)"
read YorN
if [ "$YorN" = "y" ]
	then
	remote=$(git remote)
	git push $remote head
fi

