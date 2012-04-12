#!/bin/sh
#
# SliTaz Base functions used from boot scripts to end user tools. Use
# gettext and not echo for messages. Keep output suitable for GTK boxes
# and Ncurses dialog. LibTaz should not depend on any configuration file.
# No bloated code here, function must be used by at least 3-4 tools. See
# libtaz() for a list of functions and options or run: tazdev libtaz.sh
# Libtaz is located in /lib/libtaz.sh since it is used when /usr may not
# be mounted.
#
# Copyright (C) 2012 SliTaz GNU/Linux - BSD License
#

# Internationalization.
. /usr/bin/gettext.sh
TEXTDOMAIN='slitaz-base'
export TEXTDOMAIN

# Internal variables.
okmsg="$(gettext "Done")"
ermsg="$(gettext "Failed")"
okcolor=32
ercolor=31

# Parse cmdline options.
for opt in "$@"
do
	case "$opt" in
		--raw-out)
			output="raw"
			done=" $okmsg" 
			error=" $ermsg" ;;
		--gtk-out)
			# Yad/GTK TextView bold or colored text ?
			output="gtk" 
			done=" $okmsg" 
			error=" $ermsg" ;;
		--html-out)
			output="html" 
			done=" <span class='done'>$okmsg</span>" 
			error=" <span class='error'>$ermsg</span>" ;;
	esac
done

# Help and usage.
libtaz() {
	cat << EOT

Include this library in a script:
  . /usr/lib/slitaz/libtaz.sh

Functions:
  status
  separator
  boldify string
  check_root

Options:
  --raw-out
  --gtk-out
  --html-out
 
EOT
}

# Return command status. Default to colored console output.
status() {
	local check=$?
	if [ ! "$output" ]; then
		local cols=$(stty -a | head -n 1 | cut -d ";" -f 3 | awk '{print $2}')
		local scol=$(($cols - 10))
		done="\\033[${scol}G[ \\033[1;${okcolor}m${okmsg}\\033[0;39m ]"
		error="\\033[${scol}G[ \\033[1;${ercolor}m${ermsg}\\033[0;39m ]"
	fi
	if [ $check = 0 ]; then
		echo -e "$done"
	else
		echo -e "$error"
	fi
}

# Line separator.
separator() {
	local cols=$(stty -a | head -n 1 | cut -d ";" -f 3 | awk '{print $2}')
	for c in $(seq 1 $cols); do
		echo -n "="
	done && echo ""
}

# Display a bold message. GTK Yad: Works only in --text=""
boldify() {
	case $output in
		raw) echo "$1" ;;
		gtk) echo "<b>$1</b>" ;;
		html) echo "<strong>$1</strong>" ;;
		*) echo -e "\\033[1m${1}\\033[0m" ;;
	esac
}

# Check if user is logged as root.
check_root() {
	if [ $(id -u) != 0 ]; then
		gettext "You must be root to execute:" && echo " $(basename $0) $@"
		exit 1
	fi
}
