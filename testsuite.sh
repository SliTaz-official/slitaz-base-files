#!/bin/sh
#
. rootfs/lib/libtaz.sh

echo -n "Checking libtaz.sh: status() 0"
status

echo -n "Checking libtaz.sh: status() 1"
touch /tmp/1/2/2/4 2>/dev/null
status

echo -n "Checking libtaz.sh: boldify() "
boldify "Message"

echo "Checking libtaz.sh: separator"
separator
#check_root $@

echo ""
exit 0
