#!/bin/sh
#
# SliTaz Base functions.
# Documentation: `man libtaz` or /usr/share/doc/slitaz/libtaz.txt
#
# Copyright (C) 2012-2015 SliTaz GNU/Linux - BSD License
#

. /usr/bin/gettext.sh

# Internal
lgettext() { gettext -d 'slitaz-base' "$@"; }
translate_query() {
	case $1 in
		y) lgettext "y";;
		Y) lgettext "Y";;
		n) lgettext "n";;
		N) lgettext "N";;
		# Support other cases but keep them untranslated.
		*) echo "$1" ;;
	esac
}
okmsg="$(lgettext 'Done')"
ermsg="$(lgettext 'Failed')"
: ${okcolor=32}
: ${ercolor=31}
: ${decolor=36}

# Parse cmdline options and store values in a variable.
for opt in "$@"; do
	case "$opt" in
		--*=*) export "${opt#--}";;
		--*)   export  ${opt#--}='yes';;
	esac
done
[ "$HTTP_REFERER" ] && output='html'




# i18n functions
_()  { local T="$1"; shift; printf "$(eval_gettext "$T")" "$@"; echo; }
_n() { local T="$1"; shift; printf "$(eval_gettext "$T")" "$@"; }

# Get terminal columns
get_cols() { stty size 2>/dev/null | busybox cut -d' ' -f2; }

# Last command status
status() {
	local check=$?
	case $output in
		raw|gtk)
			 done=" $okmsg"
			error=" $ermsg";;
		html)
			 done=" <span class=\"float-right color$okcolor\">$okmsg</span>"
			error=" <span class=\"float-right color$ercolor\">$ermsg</span>";;
		*)
			local cols=$(get_cols)
			local scol=$((${cols:-80} - 10))
			 done="\\033[${scol}G[ \\033[1;${okcolor}m${okmsg}\\033[0;39m ]"
			error="\\033[${scol}G[ \\033[1;${ercolor}m${ermsg}\\033[0;39m ]";;
	esac
	case $check in
		0) echo -e "$done";;
		*) echo -e "$error";;
	esac
}

# Line separator
separator() {
	case $output in
		raw|gtk) echo '--------';;
		html)    echo -n '<hr/>';;
		*)
			local cols=$(get_cols)
			printf "%${cols:-80}s\n" | tr ' ' "${1:-=}";;
	esac
}

# New line
newline() { echo; }

# Display a bold message
boldify() {
	case $output in
		raw)  echo "$@" ;;
		gtk)  echo "<b>$@</b>" ;;
		html) echo "<strong>$@</strong>" ;;
		*) echo -e "\\033[1m$@\\033[0m" ;;
	esac
}

# Colorize message
colorize() {
	: ${color=$1}
	shift
	case $output in
		raw|gtk) echo "$@";;
		html)    echo -n "<span class=\"color$color\">$@</span>";;
		*)       echo -e "\\033[1;${color:-38}m$@\\033[0;39m" ;;
	esac
	unset color
}

# Indent text
indent() {
	local in="$1"
	shift
	echo -e "\033["$in"G $@";
}

# Extended MeSsaGe output
emsg() {
	local sep="\n--------\n"
	case $output in
		raw)
			echo "$@" | sed -e 's|<b>||g; s|</b>||g; s|<c [0-9]*>||g; \
			s|</c>||g; s|<->|'$sep'|g; s|<n>|\n|g; s|<i [0-9]*>| |g' ;;
		gtk)
			echo "$@" | sed -e 's|<c [0-9]*>||g; s|</c>||g; s|<->|'$sep'|g; \
			s|<n>|\n|g; s|<i [0-9]*>| |g' ;;
		html)
			echo "$@" | sed -e 's|<b>|<strong>|g; s|</b>|</strong>|g; \
			s|<c \([0-9]*\)>|<span class="color\1">|g; s|</c>|</span>|g; \
			s|<n>|<br/>|g; s|<->|<hr/>|g; s|<i [0-9]*>| |g' ;;
		*)
			local sep="\n"
			local cols=$(get_cols)
			[ "$cols" ] || cols=80
			for c in $(seq 1 $cols); do
				sep="${sep}="
			done
			echo -en "$(echo "$@" | sed -e 's|<b>|\\033[1m|g; s|</b>|\\033[0m|g;
			s|<c \([0-9]*\)>|\\033[1;\1m|g; s|</c>|\\033[0;39m|g; s|<n>|\n|g;
			s|<->|'$sep'|g; s|<i \([0-9]*\)>|\\033[\1G|g')"
			[ "$1" != "-n" ] && echo
			;;
	esac
}

# Check if user is logged as root
check_root() {
	if [ $(id -u) != 0 ]; then
		lgettext "You must be root to execute:"; echo " $(basename $0) $@"
		exit 1
	fi
}

# Display debug info when --debug is used.
debug() {
	[ -n "$debug" ] && echo "$(colorize $decolor 'DEBUG:') $1"
}

# Confirmation
confirm() {
	if [ -n "$yes" ]; then
		true
	else
		if [ -n "$1" ]; then
			echo -n "$1 "
		else
			echo -n " ($(translate_query y)/$(translate_query N)) ? "
		fi
		read answer
		[ "$answer" == "$(translate_query y)" ]
	fi
}

# Log activities
log() {
	echo "$(date '+%Y-%m-%d %H:%M') : $@" >> ${activity:-/var/log/slitaz/libtaz.log}
}

# Print two-column list of options with descriptions
optlist() {
	local in cols col1=1 line
	in="$(echo "$1" | sed 's|		*|	|g')"
	cols=$(get_cols); [ "$cols" ] || cols=80
	IFS=$'\n'
	for line in $in; do
		col=$(echo -n "$line" | cut -f1 | wc -m)
		[ $col -gt $col1 ] && col1=$col
	done
	echo "$in" | sed 's|\t|&\n|' | fold -sw$((cols - col1 - 4)) | \
	sed "/\t/!{s|^.*$|[$((col1 + 4))G&|g}" | sed "/\t$/{N;s|.*|  &|;s|\t\n||}"
}

# Wrap words in long terminal message
longline() {
	cols=$(get_cols)
	echo -e "$@" | fold -sw${cols:-80}
}
