#!/bin/sh
#
# SliTaz Packages base functions used by packages manager, cook and
# all tools dealing with packages and receipts.
#
# Documentation: man libpkg or /usr/share/doc/slitaz/libpkg.txt
#
# Copyright (C) 2012 SliTaz GNU/Linux - BSD License
#

# Unset all receipt variables.
unset_receipt() {
	unset PACKAGE VERSION EXTRAVERSION SHORT_DESC HOST_ARCH TARBALL \
		DEPENDS BUILD_DEPENDS WANTED WGET_URL PROVIDE CROSS_BUG
}
