#!/bin/sh
PROG=${0##*/}
dir=$RPM_BUILD_ROOT/usr/share/dokuwiki
langfile=$1

echo '%defattr(644,root,root,755)' > $langfile
find $dir -type d -name lang | while read dir; do
	echo "%dir ${dir#$RPM_BUILD_ROOT}" >> $langfile
	for dir in $dir/*; do
		lang=${dir##*/}
		dir=${dir#$RPM_BUILD_ROOT}
		case "$lang" in
		zh-tw)
			lang=zh_TW
		;;
		pt-br)
			lang=pt_BR
		;;
		sl-si)
			lang=sl
		;;
		id-ni)
			lang=id_NI
		;;
		*-*)
			echo >&2 "Need mapping for $lang!"
			exit 1
		;;
		esac
		echo "%lang($lang) ${dir#$RPM_BUILD_ROOT}" >> $langfile
	done
done

if [ "$(egrep -v '(^%defattr|^$)' $langfile | wc -l)" -le 0 ]; then
	echo >&2 "$PROG: Error: international files not found!"
	exit 1
fi
