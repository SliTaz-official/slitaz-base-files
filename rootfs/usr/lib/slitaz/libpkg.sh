#!/bin/sh
#
# SliTaz Packages base functions used by packages manager, cook and
# all tools dealing with packages and receipts.
#
# Documentation: man libpkg or /usr/share/doc/slitaz/libpkg.txt
#
# Copyright (C) 2014-2015 SliTaz GNU/Linux - BSD License
#

. /lib/libtaz.sh

# Unset all receipt variables.
unset_receipt() {
	unset PACKAGE VERSION EXTRAVERSION SHORT_DESC HOST_ARCH TARBALL \
		DEPENDS BUILD_DEPENDS WANTED WGET_URL PROVIDE CROSS_BUG TAGS
}

# Converts pkg.tazpkg to pkg
package_name() {
	basename $1 .tazpkg
}

# Check mirror ID: return false if no changes or mirror unreachable
check_mirror_id() {
	[ -n "$forced" ] && rm -f ID
	[ -f 'ID' ] || echo $$ > ID
	mv ID ID.bak
	if wget -qs ${mirror%/}/ID; then
		wget -q ${mirror%/}/ID
	else
		_n 'Mirror is unreachable'
		false; status; return 1
	fi
	if [ "$(cat ID)" == "$(cat ID.bak)" ]; then
		_n 'Mirror is up-to-date'
		true; status; return 1
	fi
}

# Source a package receipt
source_receipt() {
	local receipt="$1"
	if [ ! -f $receipt ]; then
		indent 28 $(_ 'Missing receipt: %s' "$receipt")
		continue
	else
		. $receipt
	fi
}

#
# Do we realy need the code below here ???
#

# checks to see if file is proper tazpkg
is_valid_tazpkg() {
	local file="$1"
	[ -a $file ] && [ "$file" != "$(package_name $file)" ]
}

check_valid_tazpkg() {
	local file="$1"
	if ! is_valid_tazpkg $file; then
		_ 'File %s is not a tazpkg. Exiting' "$file"
		exit 1
	fi
}
