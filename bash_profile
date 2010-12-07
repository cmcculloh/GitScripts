if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

PS1='\[\033]0;$MSYSTEM:\w\007
\033[32m\]\u@\h \[\033[33m\w$(__git_ps1)\033[0m\]
\d \t $ '

alias g="git"
alias status="git status"
alias fetch="git fetch --all --prune"
alias pull="git pull fl"
alias pullscripts="source /d/automata/flgitscripts/pullscripts.sh"
alias mv="git move"
alias commit="git commit -m"
alias add="git add"
alias push="git push fl"
alias branch="git branch -a"
alias checkout="/d/automata/flgitscripts/checkout.sh"
alias merge="/d/automata/flgitscripts/merge.sh"
alias new="/d/automata/flgitscripts/new.sh"
alias delete="/d/automata/flgitscripts/delete.sh"
alias reset="git reset --hard"
alias ll="ls -l"
alias lla="ls -la"
alias cd..="cd .."
alias cls="clear"
alias home="cd /d/workspaces/fl_git/finishline"
alias gitwiki="/c/Program\ Files/Mozilla\ Firefox/firefox.exe http://10.0.2.160/wiki/index.php/Git_Commands"
alias local="/c/Program\ Files/Mozilla\ Firefox/firefox.exe http://local.finishline.com/store"
alias sshgit="ssh git@10.0.2.160"
alias prodDeploy="/d/deploys/SCRIPTS/prodDeploy.sh"
alias refresh_bash_profile="source /d/automata/flgitscripts/refresh_bash_profile.sh"
alias refreshSource="source /c/Program\ Files/Git/etc/bash_profile"
alias showlog="/d/automata/flgitscripts/showlog.sh"
alias getdiff="/d/automata/flgitscripts/showlog.sh"