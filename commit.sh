#!/bin/bash
## /*
#	@usage commit <message> [-aA]
#
#	@description
#	Commits already-staged work to a branch with a few extra benefits. The branch name
#	is prepended to the commit message so that all commits are easily associated with
#	their branch. The commit summary message is also automatically suppressed.
#
#	Non-staged work can be staged via the available options, which are described below.
#	description@
#
#	@options
#	-a	Automatically stage modified and deleted files before committing.
#	-A	Automatically stage ALL tracked/untracked files before committing.
#	options@
#
#	@notes
#	- The options for this command must come AFTER the message since the -m
#	option is automatically passed to git commit during processing.
#	- If there are untracked files in the working tree and the user passes the -a
#	option, he/she will be prompted to add the untracked files as well.
#	notes@
#
#	@examples
#	1) commit "I know I added some untracked files, so I'll pass the right option" -A
#	examples@
#
#	@dependencies
#	gitscripts/gsfunctions.sh
#	dependencies@
## */
$loadfuncs

startingBranch=$(__parse_git_branch)
if [ -z "$startingBranch" ]; then
	echo ${E}"Unable to determine current branch."${X}
	exit 1
fi


echo ${H1}
echo ${H1HL}
echo "Committing changes to branch: ${startingBranch}"
echo ${H1HL}
echo ${X}
echo

# check to see if user wants to add all modified/deleted files
if [ -n "$2" ]; then

	if [ "$2" == "-A" ] || [ "$2" == "-a" ]; then
		flag="-a"
	else
		__bad_usage commit
		exit 1
	fi

	if [ "$2" == "-A" ]; then
		echo ${H2HL}
		echo "# git add -A"
		git add -A
		echo ${H2HL}

	elif [ "$2" == "-a" ]; then
		# if there are untracked files, user may wish to stage them
		if [ "$(__parse_git_status untracked)" == "0" ]; then
			echo
			echo ${Q}"Would you like to run 'git add -A' to add untracked files as well? y (n)"${X}
			read yn
			if [ "$yn" == "y" ] || [ "$yn" == "Y" ]; then
				echo
				echo ${H2HL}
				echo "# git add -A"
				git add -A
				echo ${H2HL}
			fi
		fi
	fi
fi

echo
echo ${O}
echo ${H2HL}
echo "# git status"
git status
echo ${X}


echo
echo ${O}
echo ${H2HL}
echo "# git commit -q -m \"($startingBranch) $1\" $flag"
git commit -q -m "(${startingBranch}) $1" $flag
echo ${H2HL}
echo ${X}


echo
echo ${O}
echo ${H2HL}
echo "# git diff-tree --stat HEAD"
git diff-tree --stat HEAD
echo ${H2HL}
echo ${X}
echo
echo

echo ${H2}
echo "Would you like to push? y (n)"
echo ${X}
read YorN
if [ "$YorN" = "y" ]
	then
	remotes_string=$(git remote);
	c=0;

	for i in $remotes_string; 
	do 
	echo "$c: $i";
	c=$((c+1));
	remotes[$c]=$i;
	done

	if [ ${#remotes[@]} = 1 ]
		then
		remote=$remotes[1];
	else
		echo ${O}"------------------------------------------------------------------------------------"
		echo "Choose a remote (or just hit enter to abort):"
		echo "------------------------------------------------------------------------------------"
		for (( i = 0 ; i < ${#remotes[@]} ; i++ ))
			do
			remote=$(echo ${remotes[$i]} | sed 's/[a-zA-Z0-9\-]+(\/\{1\}[a-zA-Z0-9\-]+)//p')

			if [ $i -le "9" ] ; then
				index="  "$i
			elif [ $i -le "99" ] ; then
				index=" "$i
			else
				index=$i
			fi
			echo "$index: $remote"
		done
		echo ${I}"Choose a remote (or just hit enter to abort):"
		read remote
		echo ${X}

		remote=$(echo ${remotes[$remote]} | sed 's/\// /')
	fi

	echo "remote: $remote"
	chosenremoteexists=`git remote | grep "${remote}"`
	if [ -z "$remote" ] || [ "$remote" = "" ] ; then
		echo ${E}"####################################################################################"
		echo "ABORTING: pushing requires a remote to continue                               "
		echo "####################################################################################"
		echo ${X}
		exit 0
	elif [ -n "$chosenremoteexists" ] ; then
		echo ${h2}"You chose: ${COL_CYAN}${remote}${h2}"
		echo ${X}
		eval "git push ${remote} HEAD"

	else
		echo ${E}"You chose: ${COL_CYAN}${remote}${E}"
		echo "404 NOT FOUND. The requested REMOTE /${remote} was not found on this server."
		echo ${X}
	fi
fi









# 	echo ""
# 	echo ${O}
# 	echo "------------------------------------------------------------------------------------"
# 	echo "# git push $remote HEAD"
# 	git push $remote HEAD
# 	echo "------------------------------------------------------------------------------------"
# 	echo ${X}
# 	echo


# 	echo ${H2}
# 	echo "####################################################################################"
# 	echo "Status after push:"
# 	echo "####################################################################################"
# 	echo ${X}

# 	echo ""
# 	echo ${O}
# 	echo "------------------------------------------------------------------------------------"
# 	echo "# git status"
# 	#${STYLE_NORM}
# 	#${STYLE_BRIGHT}
# 	git status
# 	echo ${X}

# fi


#echo "Check for remote changes? (y) n"
#echo ""
#read YorN
#if [ "$YorN" = "y" ] || [ "$YorN" = "" ]
#	then
#	echo "NOT ACTUALLY CHECKING FOR CHANGES RIGHT NOW --- TBD LATER"
#fi


if [ "$clearscreenanswer" = "n" ]; 	then
	echo "Clear screen? y (n)";
	read YorN
	if [ -z "$YorN" ] && [ "$YorN" = "" ]
		then
		YorN=n
	fi
else
	echo "Clear screen? (y) n"
	read YorN
	if [ -z "$YorN" ] && [ "$YorN" = "" ]
		then
		YorN=y
	fi
fi

if [ "$YorN" = "y" ]
	then

	echo ""
	echo "Clearing screen now!"
	echo ""
	clear
fi

