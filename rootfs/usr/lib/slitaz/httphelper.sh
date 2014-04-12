#!/bin/sh
#
# SliTaz Helper for SHell CGI scripts - See httphelper function
#
# This helper is used in TazPanel, Pizza and other SliTaz CGI tools and 
# services. The goal is to maintain it according to the needs of the 
# project and Busybox httpd server applet since it is used for URL 
# [en|de]coding.
#
# Documentation: man httphelper or /usr/share/doc/slitaz/httpelper.txt
#
# Copyright (C) SliTaz 2014 - GNU GPL v2
#

alias urlencode='busybox httpd -e'
alias urldecode='busybox httpd -d'

# Send headers.
header() {
	local i
	[ -z "$1" ] && set -- "Content-type: text/html"
	for i in "$@" ""
	do 
		echo -e "$i\r"
	done
}

http_urlencode() {
	sed	-e "s|%|%25|g;s|!|%21|g;s|\*|%2A|g;s|'|%27|g;s|(|%28|g" \
		-e "s|)|%29|g;s|;|%3B|g;s|:|%3A|g;s|@|%40|g;s|&|%26|g" \
		-e "s|=|%3D|g;s|+|%2B|g;s|\$|%24|g;s|,|%2C|g;s|/|%2F|g" \
		-e "s|\?|%3F|g;s|#|%25|g;s|\[|%5B|g;s|\]|%5D|g;s| |+|g"
}

htmlentities() {
	echo $1 | sed -e 's|&|\&amp;|g;s|<|\&lt;|g;s|>|\&gt;|g' \
		-e 's|"|\&quot;|g;s|'"'"'|\&acute;|g;s|\t|\&#09;|g'
}

# MD5 crypt a string such as password (httpd -m dont give same result ?)
md5crypt() {
	echo -n "$1" | md5sum | awk '{print $1}'
}

# MD5 crypt a string. Stronger crypto than MD5
sha512crypt() {
	echo -n "$1" | sha512sum | awk '{print $1}'
}

_ARRAY()
{
[ -z "$2" ] && eval echo \$${1}__NAMES ||
	[ -n "$(eval echo \$${1}__NAMES)" ] && eval echo \$${1}_${2}_${3:-1}
}

GET()		{ _ARRAY GET	"$1" $2; }
POST()		{ _ARRAY POST	"$1" $2; }
FILE()		{ _ARRAY FILE	"$1" $2; }
COOKIE()	{ _ARRAY COOKIE	"$1" $2; }

httpinfo()
{
local i
local j
local x
env | sort | sed "s/=/='/;s/$/'/"
for x in GET POST COOKIE ; do
	for i in $($x) ; do
		if [ $($x $i count) -gt 1 ]; then
			for j in $(seq 1 $($x $i count)); do
				echo "$x($i,$j)='$($x $i $j)'"
			done
		else
			echo "$x($i)='$($x $i)'"
		fi
	done
done
for i in $(FILE) ; do
	for j in name size type tmpname ; do
		echo "FILE($i,$j)='$(FILE $i $j)'"
	done
done
}

read_query_string()
{
local i
local names
local cnt
names=""
IFS="&"
for i in $2 ; do
	var=${i%%[^A-Za-z_0-9]*}
	case " $names " in
	*\ $var\ *)	eval cnt=\$${1}_${var}_count ;;
	*)		cnt=0
			names="$names $var" ;;
	esac
	eval ${1}_${var}_count=$((++cnt))
	eval ${1}_${var}_$cnt=\'$(busybox httpd -d "${i#*=}" | sed "s/'/\'\\\\\'\'/g")\'
done
unset IFS
eval ${1}__NAMES=\'${names# }\'
}

[ -z "$GET__NAMES" ] && read_query_string GET "$QUERY_STRING"
[ -z "$COOKIE_NAMES" ] &&
	read_query_string COOKIE "$(echo "$HTTP_COOKIE" | sed 's/; /\&/g')"

ddcut()
{
page=4096
skip=$1
count=$(($2 - $1 -2))
tmp=$(($skip / $page))
[ $tmp -ne 0 ] && dd bs=$page skip=$tmp count=0 
skip=$(($skip - ($tmp * $page) ))
dd bs=1 skip=$skip count=0
tmp=$(( ($page - $skip) % $page ))
if [ $tmp -ne 0 -a $tmp -le $count ]; then
	dd bs=1 count=$tmp
	count=$(($count - $tmp))
fi
tmp=$(($count / $page))
[ $tmp -ne 0 ] && dd bs=$page count=$tmp
dd bs=1 count=$(($count - ($tmp * $page) ))
}

if [ "$REQUEST_METHOD$POST__NAMES" == "POST" ]; then
	prefix=/tmp/httpd_post
	mkdir $prefix$$
	now=$(stat -c %Y $prefix$$)
	for i in $prefix* ; do
		[ $(stat -c %Y $i) -lt $(($now - 3600)) ] && rm -rf $i
	done
	post=$prefix$$/post
	n=1
	cat > ${post}0
	read args < ${post}0
	delim="${args%?}"
	case "$delim" in
	
	-*)	awk "/$delim/ { o+=index(\$0,\"$delim\")-1; print o }
	   		  { o+=1+length() }" < ${post}0 | while read offset; do
		    if [ $offset -ne 0 ]; then
			ddcut $last $offset < ${post}0 > $post$n 2> /dev/null
			n=$(($n+1))
		    fi
		    last=$offset
		done
		rm -f ${post}0
		CR=`printf '\r'`
		for i in $post* ; do
		    head -n 2 $i | grep -q filename= || echo '' >> $i
		    filename=
		    while read line; do
			case "$line" in
			
			*Content-Disposition*)
			    name=$(echo $line | sed 's/.* name="\([^"]*\)".*$/\1/')
			    name=${name%%[^A-Za-z_0-9]*}
			    case "$line" in
			    *filename=*) filename=$(echo $line | sed 's/.* filename="\([^"]*\)".*$/\1/') ;;
			    esac ;;
			
			*Content-Type*)
			    type=$(echo $line | sed 's/.*-Type: \(.*\).$/\1/') ;;
			
			$CR)
			    if [ -n "$filename" ]; then
				tmp=$(mktemp $prefix$$/uploadXXXXXX)
				cat > $tmp
				FILE__NAMES="$FILE__NAMES $name"
				FILE__NAMES="${FILE__NAMES# }"
				eval FILE_${name}_tmpname=$tmp
				eval FILE_${name}_name=$filename
				eval FILE_${name}_size=$(stat -c %s $tmp)
				eval FILE_${name}_type=$type
			    elif [ -n "$name" ]; then
			        eval cnt=\$POST_${name}_count
			        cnt=$(($cnt + 1))
				eval var=\$POST_${name}_$cnt
				while read line; do
					[ -n "$var" ] && var="$var
"
					var="$var$line"
				done
				eval POST_${name}_$cnt="\$var"
				eval POST_${name}_count=$cnt
				case " $POST__NAMES " in
				*\ $name\ *) ;;
				*) POST__NAMES="$POST__NAMES $name"
				   POST__NAMES="${POST__NAMES# }" ;;
				esac
			    fi
			    break ;;
			*)
			esac
		    done < $i
		    rm -f $i
		done
		#rmdir $(dirname $post) 
		;;
	
	*)	
		rm -rf $(dirname $post)
		read_query_string POST "$args" ;;
	
	esac
fi
