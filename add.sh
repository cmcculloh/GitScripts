$loadfuncs


echo ${X}

#need to clean this list up
list=($(git status --porcelain | tr " " -))
msg="Please choose a file to stage. Files preceeded by a '-' are not staged; otherwise they are already staged"
__menu --prompt="$msg" ${list[@]}

gitcommand="add"
#determine if we are adding or deleting
if [[ "$_menu_sel_value" =~ D ]]
then
	gitcommand="rm"
fi

# clean the flags out of the file name
shopt -s extglob
item=${_menu_sel_value/@(M--|-M-|D--|-D-|\?\?-)/}

echo
echo
echo "Staging file ${COL_GREEN}${item}${COL_NORM} for commit."
echo ${O}${H2HL}
echo "$ git ${gitcommand} ${item}"
git ${gitcommand} ${item}
echo ${O}${H2HL}${X}
echo
echo

# Show status for informational purposes
echo "$ git status"
git status
echo ${O}${H2HL}${X}


exit