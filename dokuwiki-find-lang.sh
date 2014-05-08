#!/bin/sh
PROG=${0##*/}
if [ $# = 2 ]; then
	# for using same syntax as rpm own find-lang
	RPM_BUILD_ROOT=$1
	shift
fi
dir=$RPM_BUILD_ROOT/usr/share/dokuwiki
langfile=$1
tmp=$(mktemp) || exit 1
rc=0

find $dir -type d -name lang > $tmp

echo '%defattr(644,root,root,755)' > $langfile
while read dir; do
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
		ca-valencia)
			lang=ca@valencia
		;;
		hu-formal)
			lang=hu
		;;
		de-informal)
			lang=de
		;;
		zh-cn)
			lang=zh_CN
		;;
		*-*)
			echo >&2 "ERROR: Need mapping for $lang!"
			rc=1
		;;
		esac
		if [ "$lang" = "en" ]; then
			echo "${dir#$RPM_BUILD_ROOT}" >> $langfile
		else
			echo "%lang($lang) ${dir#$RPM_BUILD_ROOT}" >> $langfile
		fi
	done
done < $tmp

if [ "$(grep -Ev '(^%defattr|^$)' $langfile | wc -l)" -le 0 ]; then
	echo >&2 "$PROG: Error: international files not found!"
	rc=1
fi

rm -f $tmp
exit $rc
