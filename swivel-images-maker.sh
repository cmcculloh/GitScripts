givenflag=""

origDirectory=$(pwd)

if [ -n $1 ] && [ "$1" != " " ] && [ "$1" != "" ]
	then
	givenflag=$1
else 
	givenflag=$(pwd)
fi



echo "Param 2 is: $2"
spinBackwards="false"
if [ "$2" != " " ] && [ "$2" != "" ]
	then
		
		echo "Param 2 exists, is not blank!";

		if [ $2 = "--spinBackwards" ]; then
			echo "make it spin backwards!";
			spinBackwards="true"
		else 
			echo "do not make it spin backwards!";
		fi
fi

MEDIAFILEDUMP="/home/csc/Development/workspaces/ubuntu_galileo_workspace/finishline_media/media/images/swivel-images"
if [ "$3" != " " ] && [ "$3" != "" ]
	then
		
		echo "Param 3 exists, is not blank!";



		if [ -d "$3" ]; then 
			if [ -L "$3" ]; then
				echo "Given media file dump is a symlink!"

				# Symbolic link specific commands go here
				MEDIAFILEDUMP = $3
			else
				echo "Given media file dump is an actual directory!"
				# Directory command goes here
				MEDIAFILEDUMP = $3
			fi
		else
			echo "##########################################"
			echo "Error: Given param for media file dump:"
			echo "($3)"
			echo "...does not exist --- using default"
			echo "##########################################"
		fi
	else
		echo "##########################################"
		echo "Using default media file dump."
		echo "($MEDIAFILEDUMP)"
		echo "##########################################"

fi


if [ "$givenflag" == "--help" ] || [ "$givenflag" == "-help" ] || [ "$givenflag" == "-h" ] || [ "$givenflag" == "help" ]
	then

		echo "##########################################"
		echo "Swivel Images Transformation : Help "
		echo "##########################################"
		echo
		echo "No help system yet"

		exit 1
fi


LINK_OR_DIR=$givenflag


echo
echo "##########################################"
echo "Swivel Images Transformation"
echo "##########################################"
echo




if [ -d "$LINK_OR_DIR" ]; then 
	if [ -L "$LINK_OR_DIR" ]; then
		# It is a symlink!
		# Symbolic link specific commands go here
		cd "$LINK_OR_DIR"
	else
		# It's a directory!
		# Directory command goes here
		cd "$LINK_OR_DIR"
	fi
else
	echo "Error: Directory $LINK_OR_DIR does not exist"

	exit -1
fi

WORKINGDIR=$(pwd)

echo "Going to cd to directory: $WORKINGDIR"

cd $WORKINGDIR


#WORKINGDIR=$(pwd)
IMAGEBASENAME=${PWD##*/}
FINALFILEDUMP="$WORKINGDIR/$IMAGEBASENAME"

TEMPFILEDUMP="$WORKINGDIR/temp"

if [ -d $TEMPFILEDUMP ]; then 
	if [ -L $TEMPFILEDUMP ]; then
		# It is a symlink!
		# Symbolic link specific commands go here
		rm $TEMPFILEDUMP
	else
		# It's a directory!
		# Directory command goes here
		rm -r $TEMPFILEDUMP/
	fi
fi

if [ -d $FINALFILEDUMP ]; then 
	if [ -L $FINALFILEDUMP ]; then
		# It is a symlink!
		# Symbolic link specific commands go here
		rm $FINALFILEDUMP
	else
		# It's a directory!
		# Directory command goes here
		rm -r $FINALFILEDUMP/
	fi
fi



if [ $spinBackwards == "true" ]; then
	echo "DO spin it backwards"
	# Do not sort it backwards!
	FILESLIST=`ls -r $WORKINGDIR`
	echo "File list for backwards:";
	ls -lar $WORKINGDIR
else
	echo "NOT going to spin it backwards, normal"
	# sort it backwards
	FILESLIST=`ls $WORKINGDIR`
	echo "File list:";
	ls -la $WORKINGDIR
fi

NUMBEROFFILE=`ls -1  $WORKINGDIR | wc -l`





echo "Going to make directory: $TEMPFILEDUMP"
mkdir -vp "$TEMPFILEDUMP"

echo "Going to make directory: $FINALFILEDUMP"
mkdir -vp "$FINALFILEDUMP"




for Zindex in 1200 800 500 255 150 75 48   # Five lines.
# for Zindex in 800 # Five lines.
# for Zindex in 150    # Five lines.
#for Zindex in 75 32    # Five lines.
do

	Xindex=0
	Yindex="000"

	THISFILEDUMP="$TEMPFILEDUMP/z-$Zindex/y-$Yindex"
	#mkdir -r $THISFILEDUMP
	echo "Going to make directory: $THISFILEDUMP"
	mkdir -vp "$THISFILEDUMP"

	for file in $FILESLIST
	do
		# 304775-105__x-000__y-000__z-500.jpg
		XindexPadded="$Xindex"
		if [ "$XindexPadded" -lt "10" ]; then
			XindexPadded="00""$XindexPadded"
		elif [ "$XindexPadded" -lt "100" ]; then
			XindexPadded="0""$XindexPadded"

		fi
		new_file="/$IMAGEBASENAME""__x-""$XindexPadded""__y-""$Yindex""__z-""$Zindex.jpg"
		cp $file "$THISFILEDUMP""$new_file"

		targetImageWidth=`gm identify -format "%w" "$THISFILEDUMP""$new_file"`
		targetImageHeight=`gm identify -format "%h" "$THISFILEDUMP""$new_file"`
		echo "Zindex:  $Zindex";
		echo "targetImageWidth:  $targetImageWidth";
		echo "targetImageHeight: $targetImageHeight";




		echo "scale=10; ( $targetImageHeight / $targetImageWidth * $Zindex )"|bc;
		newHeight=`echo "scale=10; ( $targetImageHeight / $targetImageWidth * $Zindex )"|bc`;
		newHeightRounded=`printf %0.f $newHeight`;
		

		echo "New width: $Zindex";
		echo "New height: $newHeight";
		echo "New height rounded: $newHeightRounded";

		# gm convert -draw 'text 200,200 "'$Xindex'"' -pointsize 56 -fill "#000000" "$TEMPFILEDUMP/$new_file" "$TEMPFILEDUMP/$new_file" 
		gm convert -thumbnail $Zindexx$newHeightRounded "$THISFILEDUMP""$new_file"  -gravity center -resize $Zindex  "$THISFILEDUMP""$new_file"
		# gm convert -thumbnail $Zindexx$Zindex "$THISFILEDUMP""$new_file"  -gravity center -extent $Zindexx$Zindex "$THISFILEDUMP""$new_file"
		echo "Done with file: $THISFILEDUMP$new_file"

		Xindex=$(($Xindex+1))
	done
	lastImage="$THISFILEDUMP$new_file"
	lastImageWidth=`gm identify -format "%w" "$lastImage"`
	lastImageHeight=`gm identify -format "%h" "$lastImage"`
	echo "lastImageWidth:  $lastImageWidth";
	echo "lastImageHeight: $lastImageHeight";

	cd "$THISFILEDUMP"
	#gm convert *jpg +append -draw 'text 100,100 "%m:%f %wx%h"'  -fill "#000000" "$TEMPFILEDUMP/""$IMAGEBASENAME""__x-sprite""__y-""$Yindex""__z-""$Zindex.jpg"
	gm convert *jpg +append  "$THISFILEDUMP""/$IMAGEBASENAME""__x-sprite""__y-""$Yindex""__z-""$Zindex.jpg"



	new_properties_file="$THISFILEDUMP""/directory-properties.json"
	touch "$new_properties_file"

	# date and time the images were processed
	TIME=$(date +%k%M)
	DAY=`/bin/date +%Y-%m-%d`
	datetime_created=$DAY"-"$TIME
	echo "{" >> $new_properties_file
	echo "\"images_datetime-created\": \"$datetime_created\"," >> $new_properties_file

	# style-color of the product
	echo "\"product_style-color\": \"$IMAGEBASENAME\"," >> $new_properties_file
	# y-axis of the images in this directory
	echo "\"images_y-axis\": \"$Yindex\"," >> $new_properties_file
	#- z-index of the images in this directory
	echo "\"images_z-axis\": \"$Zindex\"," >> $new_properties_file
	#- number of steps in this directory
	echo "\"images_numberOf\": $Xindex," >> $new_properties_file
	#- image pixel width of images in this directory
	echo "\"images_width\": $lastImageWidth," >> $new_properties_file
	#- image pixel height of images in this directory		
	echo "\"images_height\": $lastImageHeight," >> $new_properties_file

	if [ $spinBackwards == "true" ]; then
		echo "\"images_spinBackwards\": \"false\"" >> $new_properties_file
	elif [ $spinBackwards == "false" ]; then
		echo "\"images_spinBackwards\": \"false\"" >> $new_properties_file
	fi

	echo "}" >> $new_properties_file

	echo "" >> $new_properties_file


	cd $WORKINGDIR


done


#mkdir "$FINALFILEDUMP/z-500"
#mkdir "$FINALFILEDUMP/z-500/y-000"
cd "$TEMPFILEDUMP"

FILESLISTTEMP=`ls`
echo "File list:";
ls -la

cp -rv  "$TEMPFILEDUMP/"* "$FINALFILEDUMP/"


echo "Copying files to media file dump now."
cp -rv  "$FINALFILEDUMP" "$MEDIAFILEDUMP/"


cd $origDirectory

echo "Done!"




