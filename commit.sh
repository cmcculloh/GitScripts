git commit -q -m "$(__git_ps1) $1" $2

git diff-tree --stat HEAD

echo


git status



echo
echo

echo "Would you like to push? (Y or N)"
read YorN
if [ "$YorN" = "Y" ]
	then
	git push fl head
fi

