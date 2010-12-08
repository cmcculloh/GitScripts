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
alias pullscripts="source ${gitscripts_path}pullscripts.sh"
alias move="git mv"
alias commit="git commit -m"
alias add="git add"
alias push="git push fl"
alias branch="git branch -a"
alias checkout="${gitscripts_path}checkout.sh"
alias merge="${gitscripts_path}merge.sh"
alias new="${gitscripts_path}new.sh"
alias delete="${gitscripts_path}delete.sh"
alias reset="git reset --hard"
alias ll="ls -l"
alias lla="ls -la"
alias cd..="cd .."
alias cls="clear"
alias home="cd ${fl_workspace}"
alias gitwiki="${firefox_home} http://10.0.2.160/wiki/index.php/Git_Commands"
alias local="${firefox_home} http://local.finishline.com/store"
alias sshgit="ssh git@10.0.2.160"
alias prodDeploy="/d/deploys/SCRIPTS/prodDeploy.sh"
alias refresh_bash_profile="source ${gitscripts_path}refresh_bash_profile.sh"
alias refreshSource="source ${native_bash_profile_path}"
alias showlog="${gitscripts_path}showlog.sh"
alias getdiff="${gitscripts_path}showlog.sh"