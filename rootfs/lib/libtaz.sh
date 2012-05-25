#!/bin/sh
#
# SliTaz Base functions used from boot scripts to end user tools. Use
# gettext and not echo for messages. Keep output suitable for GTK boxes
# and Ncurses dialog. LibTaz should not depend on any configuration file.
# No bloated code here, functions must be used by at least 3-4 tools.
#
# Documentation: man libtaz or /usr/share/doc/slitaz/libtaz.txt
#
# Copyright (C) 2012 SliTaz GNU/Linux - BSD License
#

# Internationalization. We can't export TEXTDOMAIN because this script
# includes to other scripts with other TEXTDOMAIN exported
. /usr/bin/gettext.sh

# xgettext (from Makefile) can't extract strings from above example:
# gettext -d 'slitaz-base' 'Done'
# so, I define own function (and add it as option to xgettext to Makefile)
lgettext() {
	gettext -d 'slitaz-base' $1
}

# Internal variables.
okmsg="$(lgettext 'Done')"
ermsg="$(lgettext 'Failed')"
: ${okcolor=32}
: ${ercolor=31}
: ${decolor=36}

# Parse cmdline options and store values in a variable.
for opt in "$@"
do
	case "$opt" in
		--*=*) export ${opt#--} ;;
		--*) export ${opt#--}="yes" ;;
	esac
done
[ "$HTTP_REFERER" ] && output="html"

# Get terminal columns
get_cols() {
	stty -a 2>/dev/null | head -n 1 | cut -d ";" -f 3 | awk '{print $2}'
}

# Return command status. Default to colored console output.
status() {
	local check=$?
	case $output in
		raw|gtk)
			done=" $okmsg"
			error=" $ermsg" ;;
		html)
			done=" <span style='color: $okcolor;'>$okmsg</span>"
			error=" <span style='color: $ercolor;'>$ermsg</span>" ;;
		*)
			local cols=$(get_cols)
			[ "$cols" ] || cols=80
			local scol=$(($cols - 10))
			done="\\033[${scol}G[ \\033[1;${okcolor}m${okmsg}\\033[0;39m ]"
			error="\\033[${scol}G[ \\033[1;${ercolor}m${ermsg}\\033[0;39m ]" ;;
	esac
	if [ $check = 0 ]; then
		echo -e "$done"
	else
		echo -e "$error"
	fi
}

# Line separator.
separator() {
	local sepchar="="
	[ "$HTTP_REFERER" ] && local sepchar="<hr />"
	case $output in
		raw|gtk) local sepchar="-" && local cols="8" ;;
		html) local sepchar="<hr />" ;;
		*)
			local cols=$(get_cols)
			[ "$cols" ] || cols=80 ;;
	esac
	for c in $(seq 1 $cols); do
		echo -n "$sepchar"
	done && echo ""
}

# New line for echo -n or gettext.
newline() {
	echo ""
}

# Display a bold message. GTK Yad: Works only in --text=""
boldify() {
	case $output in
		raw) echo "$@" ;;
		gtk) echo "<b>$@</b>" ;;
		html) echo "<strong>$@</strong>" ;;
		*) echo -e "\\033[1m$@\\033[0m" ;;
	esac
}

# Better to keep messages unsplitted
# Example: unboldify "My <b>pretty</b> function ;)"
unboldify() {
	case $output in
		raw)	echo "$@" | sed -e 's|<b>||g;s|</b>||g' ;;
		gtk)	echo "$@" ;;
		html)	echo "$@" | sed -e 's|<b>|<strong>|g;s|</b>|</strong>|g' ;;
		*)		echo -e "$(echo "$@" | sed -e 's|<b>|\\033[1m|g;s|</b>|\\033[0m|g')" ;;
	esac
}

# Usage: colorize "Message" colorNB or use --color=NB option
# when running a tool. Default to white/38 and no html or gtk.
colorize() {
	: ${color=$1}
	shift
	local content="$@"
	case $output in
		raw|gtk|html) echo "$content" ;;
		*)
			[ "$color" ] || color=38
			echo -e "\\033[1;${color}m${content}\\033[0;39m" ;;
	esac
	unset color
}

# Indent text $1 spaces.
indent() {
	local in="$1"
	shift
	echo -e "\033["$in"G $@";
}

# Check if user is logged as root.
check_root() {
	if [ $(id -u) != 0 ]; then
		lgettext "You must be root to execute:" && echo " $(basename $0) $@"
		exit 1
	fi
}

# Display debug info when --debug is used.
debug() {
	[ "$debug" ] && echo "$(colorize $decolor "DEBUG:") $1"
}

# Gettextize yes/no.
translate_query() {
	case $1 in
		y) lgettext "y" ;;
		Y) lgettext "Y" ;;
		n) lgettext "n" ;;
		N) lgettext "N" ;;
		# Support other cases but keep them untranslated.
		*) echo "$1" ;;
	esac
}

# Usage: echo -n "The question" && confirm
confirm() {
	[ "$yes" ] && true
	echo -n " ($(translate_query y)/$(translate_query N)) ? "
	read answer
	[ "$answer" == "$(translate_query y)" ]
}

# Log activities. $activity should be set by the script. The log format
# is suitable for web interfaces like cook. Usage: log "String"
log() {
	[ "$activity" ] || activity=/var/log/slitaz/libtaz.log
	echo "$(date '+%Y-%m-%d %H:%M') : $@" >> $activity
}
