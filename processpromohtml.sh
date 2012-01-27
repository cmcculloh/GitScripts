#1/bin/bash

# Expects first parameter to be the name of the promo (uri).
if [ -z "$1" ]; then
	echo "Error: First argument must be the name of the promo."
	exit 1
fi

source $workspace_path/myscripts/promovars.sh

export promodir="${promowebappdir}/$1"
export css="${promomediadir}/$1/css/styles.css"

if [ ! -d $promodir ]; then
	echo "Promo directory does not exist: ${promodir}"
	exit 5
fi

# check for an html file
html=$(ls $promodir | awk '/\.html?$/ { print }')

if [ -z "$html" ]; then
	echo "No HTML file found in promo directory."
	exit 6
fi

htmlfile="${promodir}/${html}"

# consider namespacing the css -- haven't decided if this is a good use of time...
# echo "If you'd like to namespace the css with a top-level id, type it now (without the #): "
# read nsid

# process the html, changing srcs and hrefs as necessary
echo -n "Processing html..."
awk -v promouri="$1" -f "${awkscriptsdir}/gethtml.awk" $htmlfile > "${promodir}/$1.index_body.jsp"
echo "done."

# grab css, appending to the stylesheet if it already has data
echo
echo -n "Processing css..."
if [ -s $htmlfile ]; then
	echo "" >> $css
	echo "/* imported from html */" >> $css
	awk -v promouri="$1" -f "${awkscriptsdir}/getstyles.awk" $htmlfile >> $css
else
	awk -v promouri="$1" -f "${awkscriptsdir}/getstyles.awk" $htmlfile > $css
fi
echo "done"

echo
echo "Delete original html file (Y/n)? "
read yesno

if [ -z "$yesno" ]; then
	rm $htmlfile
fi

exit 0