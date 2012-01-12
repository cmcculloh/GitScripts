#!/bin/bash


echo
if [ "$clearscreenanswer" == "n" ] || [ "$clearscreenanswer" == "N" ]; 	then
	defO=" y (n)"
	defA="n"
else
	defO=" (y) n"
	defA="y"
fi

echo ${I}"Clear screen?"${defO}${X};
read josephsCoatOfManyAnswersVariableHasA_VeryGoodName_Sir

if [ -z "$josephsCoatOfManyAnswersVariableHasA_VeryGoodName_Sir" ]; then
	josephsCoatOfManyAnswersVariableHasA_VeryGoodName_Sir=$defA
fi

if [ "$josephsCoatOfManyAnswersVariableHasA_VeryGoodName_Sir" == "y" ] ||  [ "$josephsCoatOfManyAnswersVariableHasA_VeryGoodName_Sir" == "Y" ] || [ "$josephsCoatOfManyAnswersVariableHasA_VeryGoodName_Sir" == "yes" ] ||  [ "$josephsCoatOfManyAnswersVariableHasA_VeryGoodName_Sir" == "Yes" ] ||  [ "$josephsCoatOfManyAnswersVariableHasA_VeryGoodName_Sir" == "Yes" ]; then
	clear
fi
