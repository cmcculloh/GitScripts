cd ${gitscripts_path}

git pull origin master

git add -A
git commit -m "auto commit: $1"


git push origin master