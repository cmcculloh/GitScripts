git commit -q -m "$(__git_ps1) $1" $2

git diff-tree --stat HEAD

echo


git status
