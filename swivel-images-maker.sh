source ${gitscripts_path}stack.sh

givenflag=""

if [ -n $1 ] && [ "$1" != " " ] && [ "$1" != "" ]
	then
	givenflag=$1
else 
	givenflag=$(pwd)
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

IMAGEBASEDIR=$(pwd)
WORKINGDIR=$(pwd)
IMAGEBASENAME=${PWD##*/}

TEMPFILEDUMP="$WORKINGDIR/temp"

if [ -d "$TEMPFILEDUMP" ]; then 
    if [ -L "$TEMPFILEDUMP" ]; then
        # It is a symlink!
        # Symbolic link specific commands go here
        rm "$TEMPFILEDUMP"
    else
        # It's a directory!
        # Directory command goes here
        rm -r "$TEMPFILEDUMP"
    fi
fi


FILESLIST=`ls $WORKINGDIR`
cd $WORKINGDIR


mkdir "$TEMPFILEDUMP"

Xindex=0
Yindex="000"
Zindex="500"

for file in $FILESLIST
do
	#if [ -d $file ]; then
		
	#fi
	# 304775-105__x-000__y-000__z-500.jpg
	XindexPadded=$Xindex
	if [ "$XindexPadded" -lt "10" ]; then
		XindexPadded="00$XindexPadded"
	elif [ "$XindexPadded" -lt "100" ]; then
		XindexPadded="0$XindexPadded"

	fi
	new_file="$IMAGEBASENAME""__x-""$XindexPadded""__y-""$Yindex""__z-""$Zindex.jpg"
	cp $file "$TEMPFILEDUMP/$new_file"
	Xindex=$(($Xindex+1))
done
lastImage="$TEMPFILEDUMP/$new_file"
lastImageWidth=`identify -format "%w" "$lastImage"`
lastImageHeight=`identify -format "%h" "$lastImage"`

convert *jpg -font Arial -pointsize 20 -draw gravity south fill black  text 0,12 'Copyright'  +append "$TEMPFILEDUMP/""$IMAGEBASENAME""__x-sprite""__y-""$Yindex""__z-""$Zindex.jpg"



new_properties_file="$TEMPFILEDUMP/directory.properties"
touch "$new_properties_file"

# date and time the images were processed
TIME=$(date +%k%M)
DAY=`/bin/date +%Y-%m-%d`
datetime_created=$DAY"-"$TIME
echo "images.datetime_created=$datetime_created" >> $new_properties_file

# style-color of the product
echo "product.style-color=$IMAGEBASENAME" >> $new_properties_file
# y-axis of the images in this directory
echo "images.y-axis=$Yindex" >> $new_properties_file
#- z-index of the images in this directory
echo "images.z-axis=$Zindex" >> $new_properties_file
#- number of steps in this directory
echo "images.numberOf=$Xindex" >> $new_properties_file
#- image pixel width of images in this directory
echo "images.width=$lastImageWidth" >> $new_properties_file
#- image pixel height of images in this directory		
echo "images.height=$lastImageHeight" >> $new_properties_file
echo "" >> $new_properties_file




