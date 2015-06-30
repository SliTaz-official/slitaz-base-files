#!/bin/sh
#
. rootfs/lib/libtaz.sh

check_libtaz() {
	newline; longline "This package provides the base system files and \
directories, it is built using a wok receipt and Cookutils. The creation of \
the initial files are described in the SliTaz Scratchbook: http://www.slitaz.\
org/en/doc/scratchbook/"


	title 'Available functions list:'

	optlist "\
_		Alias for gettext function with newline. Can be used with success both instead of gettext and eval_gettext.
_n		Alias for gettext function without newline at end.
_p		Alias for plural gettext function.
get_cols	Get width of current terminal emulator or console. Number in columns.
status		Output localized short message based on the previous command exit status (0 - OK, other than 0 - error).
separator	Line separator for full terminal width.
newline		Produces empty line.
boldify		Display a bold message.
colorize	Color messages for terminal.
indent		Jump to specified column, useful for simple tabulated lists (tables).
emsg		All-in-one tool that contains: boldify, colorize, newline, separator and indent.
check_root	Check if user has root permissions (logged as root or used su for becoming root) for executing something.
debug		Display debug info when --debug is used.
confirm		Used at end of questions - adds '(y/N)?' and waits for answer. Press 'y' if yes, any other letters/words or just Enter - if no. 
		Note that 'y' and 'N' can be localized and this function knows about that.
log		Log activities in /var/log/slitaz/libtaz.log (by default) or in specified log file.
optlist		Sophisticated, UTF-8 friendly, function to print two-column list of options with descriptions.
longline	Doesn't break words into two lines of terminal when displaying long messages.
title		Print localized title.
footer		Print footer.
action		Print action.
itemize		Print long line as list item, check for markers: colon (:), dash (-), and asterisk (*)."
	separator '~'; newline


	action 'Checking libtaz.sh: status() 0'
	status

	action 'Checking libtaz.sh: status() 1'
	touch /tmp/1/2/2/4 2>/dev/null
	status

	action 'Checking libtaz.sh: boldify() '
	boldify "Message"

	action 'Checking libtaz.sh: colorize() '
	echo -n $(colorize 33 "Message ")
	echo -n $(colorize 35 "Message ")
	colorize 36 "Message"

	action 'Checking libtaz.sh: separator'; newline
	separator

	action 'Checking libtaz.sh: emsg() '
	emsg '<b>bold</b> color: <c 31>bold red</c> <c 32>bold green</c> separator:<->newline:<n> message with<i 26>indent'

	itemize "Fish: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed\
 do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad mini\
m veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commo\
do consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse ci\
llum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non pro\
ident, sunt in culpa qui officia deserunt mollit anim id est laborum."

	newline

	itemize "  * Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed d\
o eiusmod tempor incididunt ut labore et dolore magna aliqua."
	itemize "  * Ut enim ad minim veniam, quis nostrud exercitation ullamco lab\
oris nisi ut aliquip ex ea commodo consequat."
	itemize "  * Duis aute irure dolor in reprehenderit in voluptate velit esse\
 cillum dolore eu fugiat nulla pariatur."
	itemize "  * Excepteur sint occaecat cupidatat non proident, sunt in culpa \
qui officia deserunt mollit anim id est laborum."


	newline; echo 'Using itemize() in the tazpkg:'
	tazpkg info gtk+

	title "$(emsg '<c 31>C<c 32>o<c 33>l<c 34>o<c 35>r<c 36>s</c>')"
	for i in $(seq 0 7); do
		case $i in
			0) c='Gray   ';;
			1) c='Red    ';;
			2) c='Green  ';;
			3) c='Yellow ';;
			4) c='Blue   ';;
			5) c='Magenta';;
			6) c='Cyan   ';;
			7) c='White  ';;
		esac
		echo -n "$c "
		echo -n "$(colorize "03$i" "03$i") $(colorize "3$i" "3$i") " # test `colorize`: fg
		echo -n "$(colorize "04$i" "04$i") $(colorize "4$i" "4$i") " # test `colorize`: bg
		echo -n ": "
		emsg "<c 03$i>03$i $c</c> <c 3$i>3$i Bold $c</c> <c 04$i>04$i $c</c> <c 4$i>4$i Bold $c</c>" # test `emsg`
	done
}

# Usage: check_functions path/to/lib.sh
check_functions() {
	lib="$1"
	echo -n "$(boldify "Checking: $(basename $lib) functions")"
	indent 34 "$(colorize 32 $(grep "[a-z_]() {" $lib | wc -l))"
	separator
	grep "[a-z_]() *{" $lib | while read line; do
		func=`echo "$line" | cut -d'(' -f1`
		count='0'
		usage='0'
		for tool in /usr/bin/cook* /usr/bin/taz* /usr/bin/spk* /usr/sbin/spk* \
			/sbin/taz* /sbin/hwsetup /var/www/cgi-bin/* /var/www/cooker/*.cgi \
			/var/www/tazpanel/*.cgi 
		do
			[ -x "$tool" ] || continue
			count=$(grep "$func[^a-z]" $tool | wc -l)
			usage=$(($usage + $count))
		done
		printf '%-34s%4d\n' "Checking: ${func}()" "$usage"
	done
	separator
}

#clear
action 'Checking libtaz.sh: log()'
activity='/tmp/testsuite.log'
log 'Message from SliTaz testsuite'
status
cat $activity
rm -f $activity

check_libtaz
output='raw'
title 'Checking libtaz.sh: --output=raw'
check_libtaz

# Check libtaz.sh functions usage
output='term'
check_functions 'rootfs/lib/libtaz.sh'

# Check libpkg.sh functions usage
check_functions 'rootfs/usr/lib/slitaz/libpkg.sh'

[ -n "$forced" ] && echo "Checking option: forced=$forced"
[ -n "$root" ] && echo "Checking option: root=$root"
[ -z "$1" ] && echo "Check options: $(basename $0) --forced --root=/dev/null"
exit 0
