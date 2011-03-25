${gitscripts_path}checkout.sh master

for branch in `git branch`
do
	wellformed=`git branch | grep "${branch}"`
	if [ -n "$wellformed" ]
		then
		masterContains=`git branch --contains "${branch}" | grep "master"`
		if [ -n "$masterContains" ]
			then
			if [ "$branch" != "master" ]
				then
				echo
				echo "git branch --contains \"${branch}\""
				echo "indicates the following branches appear to have this branch merged into them:"
				git branch --contains "${branch}"
				echo
				echo "  delete $branch? (y) n"
				read decision
				if [ -z $decision ] || [ "$decision" = "y" ]
					then
					echo "git branch -d $branch"
					${gitscripts_path}delete.sh $branch
				fi
			fi
		fi
	fi
done
