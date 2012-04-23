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
	
	echo "Checking libtaz.sh: separator"
	separator
}

check_libtaz
output="raw"
check_libtaz

[ "$forced" ] && echo "Checking option: forced=$forced"
[ "$root" ] && echo "Checking option: root=$root"
[ ! "$1" ] && echo "Check options: $(basename $0) --forced --root=/dev/null"

exit 0
