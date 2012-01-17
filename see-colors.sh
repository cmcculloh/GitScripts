#!/bin/bash
## /*
#	@usage seecolors [test-text]
#
#	@description
#	This file echoes a bunch of color codes to the terminal to demonstrate what's available.  Each
#	line is the color code of one foreground color, out of 17 (default + 16 escapes), followed by a
#	test use of that color on all nine background colors (default + 8 escapes).
#
#	Each table cell has the same text within to get a sense of comparison. This text can be
#	specified as the only parameter when calling this script. The script specifying numbers is
#	followed by another color script which does not have numbers specified.
#	description@
#
#	@notes
#	-
#	notes@
#
#	@examples
#	1)
#	examples@
## */


# The test text. Can be specified with optional first parameter.
T='jMx'
if [ -n "$1" ]; then
	T="$1"
fi

echo
echo ${H1}${H1HL}
echo "  Color table for your shell  "
echo ${H1HL}${X}
echo
echo ${O}"The column heading numbers denote background colors, while the row label numbers denote foreground colors."${X}
echo
echo -e "\n                 40m     41m     42m     43m\
     44m     45m     46m     47m";

for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
           '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
           '  36m' '1;36m' '  37m' '1;37m'; do
	FG=${FGs// /}
	echo -en " $FGs \033[$FG  $T  "

	for BG in 40m 41m 42m 43m 44m 45m 46m 47m; do
		echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m";
	done
	echo;
done


#  colors v1.03
#
#  A simple shell script to output an ANSI terminal color chart.
#  It may be useful when trying to customize your ANSI terminal
#  color scheme!
#
#  Written and placed in the public domain by Ian Abbott <ian@abbott.org>
#
#  ANSI terminal color chart generator
#  Author: Ian Abbott
#  License: BSD License, http://www.opensource.org/licenses/bsd-license.php
#  URL: http://www.snippetcenter.org/de/ansi-terminal-color-chart-generator-s1346.aspx

echo
for h in 0 1; do
	echo -e "\\033[0;${h}m\\c"
	case $h in
		0) echo -e "Normal\\c" ;;
		1) echo -e "High\\c" ;;
	esac
	echo -e " intensity foreground (background color in parentheses)\\033[m"
	for f in 0 1 2 3 4 5 6 7; do
		for b in 0 1 2 3 4 5 6 7 8; do
			echo -e "\\033[${h};3${f}\\c"
			if [ $b -lt 8 ]; then
				echo -e ";4${b}m\\c"
			else
				echo -e "m\\c"
			fi

			case $f in
				0) echo -e " BLACK \\c" ;;
				1) echo -e "  RED  \\c" ;;
				2) echo -e " GREEN \\c" ;;
				3) echo -e " YELLOW\\c" ;;
				4) echo -e "  BLUE \\c" ;;
				5) echo -e "MAGENTA\\c" ;;
				6) echo -e "  CYAN \\c" ;;
				7) echo -e " WHITE \\c" ;;
			esac
			case $b in
				8) echo -e "\\033[m" ;;
				*) echo -e " \\033[m \\c" ;;
			esac
		done
	done

	echo -e "\\033[${h}m\\c"
	for b in 0 1 2 3 4 5 6 7 8; do
		case $b in
			0) echo -e "(black)  \\c" ;;
			1) echo -e " (red)   \\c" ;;
			2) echo -e "(green)  \\c" ;;
			3) echo -e "(yellow) \\c" ;;
			4) echo -e " (blue)  \\c" ;;
			5) echo -e "(magenta)\\c" ;;
			6) echo -e " (cyan)  \\c" ;;
			7) echo -e "(white)  \\c" ;;
			8) echo -e " (none)\\c" ;;
		esac
	done
	echo -e "\\033[m\\n"
done
