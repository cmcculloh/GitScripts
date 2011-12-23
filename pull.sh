STYLE_BRIGHT=$'\033[1m'
STYLE_DIM=$'\033[2m'
STYLE_NORM=$'\033[0m'
COL_RED=$'\033[31m'
COL_GREEN=$'\033[32m'
COL_VIOLET=$'\033[34m'
COL_YELLOW=$'\033[33m'
COL_MAG=$'\033[35m'
COL_CYAN=$'\033[36m'
COL_WHITE=$'\033[37m'
COL_NORM=$'\033[39m'



echo "##########################################"
echo " pulling ${COL_CYAN}$(git remote)${COL_NORM}/${COL_CYAN}$(cb)${COL_NORM}"
echo "##########################################"
echo
echo

git pull $(git remote) $(cb)