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

# Display receipt information.
receipt_info() {
	cat << EOT
$(gettext "Version    :") ${VERSION}${EXTRAVERSION}
$(gettext "Short desc :") $SHORT_DESC
$(gettext "Category   :") $CATEGORY
EOT
}

# converts /tmp/pkg.tazpkg to pkg
package_name() {
	local name=$(basename $1)
	echo ${name%.tazpkg}
}

# checks to see if file is proper tazpkg
is_valid_tazpkg() {
	local file=$1
	local file_dir=$(base_path $file)
	[ -a $file ] && [ "$file" != "$(package_name $file)" ]
}

check_valid_tazpkg() {
	local file=$1
	if ! is_valid_tazpkg $file; then
		gettext "$file is not a tazpkg. Exiting"; newline
		exit 1
	fi
}
