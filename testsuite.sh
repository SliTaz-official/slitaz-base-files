#!/bin/sh
#
. rootfs/lib/libtaz.sh

check_libtaz() {
	newline; longline "This package provides the base system files and \
directories, it is built using a wok receipt and Cookutils. The creation of \
the initial files are described in the SliTaz Scratchbook: http://www.slitaz.\
org/en/doc/scratchbook/"

	newline; boldify Available functions list:
	separator
	optlist "\
_		Alias for eval_gettext with newline. Can be used with success both instead of gettext and eval_gettext.
_n		Alias for eval_gettext without newline at end.
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
longline	Doesn't break words into two lines of terminal when displaying long messages."
	separator; newline


	echo -n "Checking libtaz.sh: status() 0"
	status

	echo -n "Checking libtaz.sh: status() 1"
	touch /tmp/1/2/2/4 2>/dev/null
	status

	echo -n "Checking libtaz.sh: boldify() "
	boldify "Message"

	echo -n "Checking libtaz.sh: colorize() "
	echo -n $(colorize 33 "Message ")
	echo -n $(colorize 35 "Message ")
	colorize 36 "Message"

	echo "Checking libtaz.sh: separator"
	separator

	echo -n "Checking libtaz.sh: emsg() "
	emsg "<b>bold</b> color: <c 31>bold red</c> <c 32>bold green</c> separator:<->newline:<n> message with<i 26>indent"
}

# Usage: check_functions path/to/lib.sh
check_functions() {
	lib=$1
	echo -n "$(boldify "Checking: $(basename $lib) functions")"
	indent 34 "$(colorize 32 $(grep "[a-z]() {" $lib | wc -l))"
	separator
	grep "[a-z]() {" $lib | while read line
	do
		func=`echo "$line" | cut -d '(' -f 1`
		count=0
		usage=0
		echo -n "Checking: ${func}()"
		for tool in /usr/bin/cook* /usr/bin/taz* /usr/bin/spk* /usr/sbin/spk* \
			/sbin/taz* /sbin/hwsetup /var/www/cgi-bin/* /var/www/cooker/*.cgi \
			/var/www/tazpanel/*.cgi 
		do
			[ -x "$tool" ] || continue
			count=$(grep "$func" $tool | wc -l)
			usage=$(($usage + $count))
		done
		indent 34 "$usage"
	done
	separator
}

#clear
echo -n "Checking libtaz.sh: log()"
activity=/tmp/testsuite.log
log "Message from SliTaz testsuite"
status
cat $activity
rm -f $activity

check_libtaz
output="raw"
echo -e "\nChecking libtaz.sh: --output=raw"
check_libtaz

# Check libtaz.sh functions usage
output="term"
check_functions 'rootfs/lib/libtaz.sh'

# Check libpkg.sh functions usage
check_functions 'rootfs/usr/lib/slitaz/libpkg.sh'

[ "$forced" ] && echo "Checking option: forced=$forced"
[ "$root" ] && echo "Checking option: root=$root"
[ ! "$1" ] && echo "Check options: $(basename $0) --forced --root=/dev/null"
exit 0
