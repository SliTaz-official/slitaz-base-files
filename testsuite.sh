#!/bin/sh
#
. rootfs/lib/libtaz.sh

check_libtaz() {
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
			/sbin/taz*
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
echo "Checking libtaz.sh: --output=raw"
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
