cd ${gitscripts_path}

git pull origin master

git status
git add -A
git status
git commit -m "auto commit: $1"
git status

git push origin master