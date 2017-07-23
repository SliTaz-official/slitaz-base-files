#!/bin/sh
#
. ./rootfs/lib/libtaz.sh

[ $# -eq 0 ] && title 'Check variables import using libtaz.sh'

if [ "$1" == 'test' ]; then env; exit 0; fi

ME=$(realpath $0); n=/tmp/n; echo 1 > $n; tests=18

t() {
	i=$(cat $n)
	printf "%2d/%d: %-16s: test %s" "$i" "$tests" "$1" "$2 $3" >&2
	$ME test "$2" "$3"
	echo $((i + 1)) > $n
}

t 'without dashes'     install              | grep -qv '^install=';          status
t 'single dash'       -install              | grep -qv '^install=';          status
t 'with dashes'      --install              | grep -q '^install=yes$';       status
t 'empty 1'          --install=             | grep -q '^install=$';          status
t 'non-empty'        --install=value        | grep -q '^install=value$';     status
t 'single quotes'    --install='value'      | grep -q '^install=value$';     status
t 'double quotes'    --install="value"      | grep -q '^install=value$';     status
t 'double "=" 1'     --install=all=true     | grep -q '^install=all=true$';  status
t 'double "=" 2'     --install==double      | grep -q '^install==double$';   status
t 'spaces 1'         --install="a bb  ccc"  | grep -q '^install=a bb  ccc$'; status
t 'spaces 2'         --install=a\ bb\ \ ccc | grep -q '^install=a bb  ccc$'; status
t 'start with digit' --7zip                 | grep -q '^_7zip=yes$';         status
t 'extra dashes 1'   ----install            | grep -q '^__install=yes$';     status
t 'extra dashes 2'   --ins--tall            | grep -q '^ins__tall=yes$';     status
t 'extra dashes 3'   --ins-tall             | grep -q '^ins_tall=yes$';      status
t 'extra dashes 4'   --ins-tall=ins-tall    | grep -q '^ins_tall=ins-tall$'; status
t 'repeated'         --abc=1 --abc=2        | grep -q '^abc=2$';             status
t 'dollar sign'      --a\$bc=a\$bc          | grep -q '^a_bc=a\$bc$';        status

footer 'Tests completed'
rm $n
