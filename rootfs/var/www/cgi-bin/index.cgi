#!/bin/sh
#
# Directory lister for BusyBox HTTPd
# Copyright (C) 2014 SliTaz GNU/Linux - BSD License
#
. /usr/lib/slitaz/httphelper.sh
header

# Security check
case "$QUERY_STRING" in
	..*) echo "Security exit" && exit 1 ;;
esac

# HTML5 head
cat <<EOT
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Index of /$QUERY_STRING</title>
	<link rel="stylesheet" href="/style.css">
	<style>
		#header h1 { width: auto; }
		ul { line-height: 1.5em; } li { color: #666; }
	</style>
</head>
<body>
<div id="header">
	<h1>Index of /$QUERY_STRING</h1>
</div>
<section id="content">
<div>Files: $(ls ../$QUERY_STRING | wc -l)</div>
<ul>
EOT

[ "$QUERY_STRING" ] && echo '<li><a href="../">../</a></li>'

# We need ?/path
for i in $(ls -p ../$QUERY_STRING)
do
	if [ -f "../$QUERY_STRING/$i" ]; then
		echo "<li><a href='/${QUERY_STRING}${i}'>$i</a></li>"
	else
		echo "<li><a href='/${QUERY_STRING}${i}?${QUERY_STRING}${i}'>$i</a></li>"
	fi
done

cat << EOT
</ul>
</section>
<footer id="footer"></footer>
</body>
</html>
EOT
