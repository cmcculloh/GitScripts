# Git command-specific aliases, these do not call .sh files, but rather, are just shortcuts for basic git commands
alias addall="git add -A"
alias fetch="git fetch --all --prune"
alias move="git mv"
alias reset="git reset --hard"
alias stash="git stash"
alias status="echo ${O}; git status; echo ${X}"
alias unstash="git stash apply"
alias untrack="git rm"
