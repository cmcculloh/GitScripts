#!/bin/bash
## /*
#	@usage processpromohtml <promo-name>
#
#	@description
#	This script will take an HTML file placed in an existing promo directory
#			e.g. /global/promos/<promo-name>
#	and extract any css from an existing <style> tags and any HTML between
#	the body tags. It places the HTML in the *.index_body.jsp and any css
#	in a style.css file on the media server. It also corrects any links
#	to images as well as links to the finishline.com home page by making
#	them relative to the site root on flmedia and fl, respectively.
#	description@
#
#	@notes
#	- The awkscript which processes the promo relies on the html being wrapped
#	  in <body></body> tags. Script will fail if they are missing.
#	notes@
#
#	@examples
#	1) processpromohtml college-hooded-sweatshirt
#	examples@
#
#	@dependencies
#	awkscripts/gethtml.awk
#	awkscripts/getstyles.awk
#	gitscripts/functions/0100.bad_usage.sh
#	dependencies@
## */
$loadfuncs


# Expects first parameter to be the name of the promo (uri).
if [ -z "$1" ]; then
	__bad_usage processpromohtml "First argument must be the name of the promo."
	exit 1
fi

promouri="$1"
promodir="${promos_path}${promouri}"
css="${mediaLandingPagesPath}${promouri}/css/styles.css"

echo ${X}

if [ ! -d "$promodir" ]; then
	echo ${E}"  Promo directory does not exist: ${promodir}  "
	echo "  Aborting...  "${X}
	exit 5
fi

# check for an html file
html=$(ls "$promodir" | awk '/\.html?$/ { print; }')

if [ -z "$html" ]; then
	echo ${E}"  No HTML file found in promo directory. Aborting...  "${X}
	exit 6
fi

htmlfile="${promodir}/${html}"

# consider namespacing the css -- haven't decided if this is a good use of time...
# echo "If you'd like to namespace the css with a top-level id, type it now (without the #): "
# read nsid


# certain tags are required for successful processing. Make sure they are there...
if ! grep -q "<body>" "$htmlfile"; then
	echo
	echo ${E}"  HTML is missing the <body> tag. Aborting processing...  "${X}
	exit 2
fi

# process the html, changing srcs and hrefs as necessary
echo -n "Processing html..."
awk -v promouri="$promouri" -f "${awkscripts_path}gethtml.awk" "$htmlfile" > "${promodir}/${promouri}.index_body.jsp"
echo ${COL_GREEN}"done${X}."

# grab css, appending to the stylesheet if it already has data
echo
echo -n "Processing css..."
if [ -s "$css" ]; then
	echo "" >> "$css"
	echo "/* imported from html */" >> "$css"
	awk -v promouri="$promouri" -f "${awkscripts_path}getstyles.awk" "$htmlfile" >> "$css"
else
	awk -v promouri="$promouri" -f "${awkscripts_path}getstyles.awk" "$htmlfile" > "$css"
fi
echo ${COL_GREEN}"done${X}."

echo
echo ${Q}"${A}Delete${Q} original html file? (y) n"
read yesno

if [ -z "$yesno" ] || [ "$yesno" = "y" ] || [ "$yesno" = "Y" ]; then
	rm "$htmlfile"
fi

echo
echo "HTML processing is complete."

exit 0