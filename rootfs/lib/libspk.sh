#!/bin/sh
# LibSpk - SliTaz Package Managment Library
#
# Just some guesses as to what should be in libspk
#
# Authors : See the AUTHORS filesi

TMP_DIR=/tmp/$RANDOM

# takes a file or directory and returns the base directory
base_path() {
	local path=$1
	echo ${path%$(basename $path)}
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

valid_tazpkg() {
	local file=$1
	if ! is_valid_tazpkg $file; then
		gettext "$file is not a tazpkg. Exiting"; newline
		exit 1
	fi
}

# Display receipt information.
receipt_info() {
	cat << EOT
$(gettext "Version    :") ${VERSION}${EXTRAVERSION}
$(gettext "Short desc :") $SHORT_DESC
$(gettext "Category   :") $CATEGORY
EOT
}

# Unset all receipt variables.
unset_receipt() {
	unset PACKAGE VERSION EXTRAVERSION SHORT_DESC HOST_ARCH TARBALL \
		DEPENDS BUILD_DEPENDS WANTED WGET_URL PROVIDE CROSS_BUG
}

# Used by: list
count_installed() {
	count=$(ls $installed | wc -l)
	gettext "Installed packages"; echo ": $count"
}

# Used by: list
count_mirrored() {
	count=$(cat $pkgsmd5 | wc -l)
	gettext "Mirrored packages"; echo ": $count"
}





newline() {
	echo
}
