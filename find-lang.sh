#!/bin/sh

# find-lang - automagically generate list of language specific files
# for inclusion in an rpm spec file.
# This does assume that the *.mo files are under .../share/locale/...
# Run with no arguments gets a usage message.

# findlang is copyright (c) 1998 by W. L. Estes <wlestes@uncg.edu>

# Redistribution and use of this software are hereby permitted for any
# purpose as long as this notice and the above copyright notice remain
# in tact and are included with any redistribution of this file or any
# work based on this file.

# Changes:
#
# 2012-12-22 Elan Ruusamäe <glen@pld-linux.org>
#   * added --with-mate
# 2006-08-28 Elan Ruusamäe <glen@pld-linux.org>
#   * fixed --all-name which got broken with last change.
# 2006-08-09 Elan Ruusamäe <glen@pld-linux.org>
#   * huge performance boost for packages calling %find_lang multiple times (kde*i18n)
# 2001-01-08 Michał Kochanowicz <mkochano@pld.org.pl>
#   * --all-name support for KDE.
# 2000-11-28 Rafał Cygnarowski <pascalek@pld.org.pl>
#   * next simple rule for KDE
# 2000-11-12 Rafał Cygnarowski <pascalek@pld.org.pl>
#   * simple rules for KDE help files
# 2000-06-05 Michał Kochanowicz <mkochano@pld.org.pl>
#   * exact, not substring matching $NAME, i.e. find-lang top_dir NAME will
#     no longer find /usr/share/locale/pl/LC_MESSAGES/<anything>NAME.mo.
# 2000-04-17 Arkadiusz Miśkiewicz <misiek@pld.org.pl>
#   * exit 1 when no files found
# 1999-10-19 Artur Frysiak <wiget@pld.org.pl>
#   * added support for GNOME help files
#   * start support for KDE help files

PROG=${0##*/}
VERSION=1.36

usage () {
cat <<EOF
Usage: $PROG TOP_DIR PACKAGE_NAME [prefix]

where TOP_DIR is
the top of the tree containing the files to be processed--should be
\$RPM_BUILD_ROOT usually. TOP_DIR gets sed'd out of the output list.
PACKAGE_NAME is the %{name} of the package. This should also be
the basename of the .mo files.  the output is written to
PACKAGE_NAME.lang unless \$3 is given in which case output is written
to \$3.
Additional options:
  --with-gnome		find GNOME help files
  --with-mate		find MATE help files
  --with-kde		find KDE help files
  --with-omf		find OMF files
  --with-qm			find QT .qm files
  --all-name		match all package/domain names
  --without-mo		skip *.mo locale files
  -o NAME			output will be saved to NAME
  -a NAME			output will be appended to NAME
EOF
exit 1
}

if [ -z "$1" ]; then
	usage
elif [ $1 = / ]; then
	echo >&2 "$PROG: expects non-/ argument for '$1'"
	exit 1
elif [ ! -d $1 ]; then
	echo >&2 "$PROG: $1: No such directory"
	exit 1
else
	TOP_DIR="${1%/}"
fi
shift

if [ -z "$1" ]; then
   	usage
else
   	NAME=$1
fi
shift

GNOME='#'
MATE='#'
KDE='#'
OMF='#'
QM='#'
MO=''
OUTPUT=$NAME.lang
ALL_NAME='#'
NO_ALL_NAME=''
APPEND=''
while test $# -gt 0; do
    case "$1" in
	--with-gnome)
  		GNOME=''
		echo >&2 "$PROG: Enabling with GNOME"
		shift
		;;
	--with-mate)
  		MATE=''
		echo >&2 "$PROG: Enabling with MATE"
		shift
		;;
	--with-kde)
		echo >&2 "$PROG: Enabling with KDE"
		KDE=''
		shift
		;;
	--with-omf)
		echo >&2 "$PROG: Enabling with OMF"
		OMF=''
		shift
		;;
	--with-qm)
		echo >&2 "$PROG: Enabling with Qt QM"
		QM=''
		shift
		;;
	--without-mo)
		echo >&2 "$PROG: Disabling .mo files"
		MO='#'
		shift
		;;
	--all-name)
		echo >&2 "$PROG: Enabling with all names"
		ALL_NAME=''
		NO_ALL_NAME='#'
		shift
		;;
	-o)
		shift
		OUTPUT=$1
		shift
		;;
	-a)
		shift
		OUTPUT=$1
		APPEND='>'
		shift
		;;
	*)
		OUTPUT=$1
		shift
		;;
    esac
done

echo >&2 "$PROG/$VERSION: find-lang '$NAME' $APPEND> $OUTPUT"

MO_NAME=.$OUTPUT.tmp~
echo '%defattr(644,root,root,755)' > $MO_NAME

# .mo
if [ ! -f __find.files ] || [ "$TOP_DIR" -nt __find.files ]; then
	find $TOP_DIR -xtype f -name '*.mo' | xargs -r file -L | \
	sed -e '
		/, 1 messages$/d
		s/:.*//
		s:'"$TOP_DIR"'::' > __find.files
else
	echo >&2 "$PROG: Using cached __find.files"
fi

# .omf
if [ ! -f __omf.files ] || [ "$TOP_DIR" -nt __omf.files ]; then
	find $TOP_DIR -type f -name '*.omf' | \
	sed -e '
		s:'"$TOP_DIR"'::' > __omf.files
else
	echo >&2 "$PROG: Using cached __omf.files"
fi

# .qm
if [ ! -f __qm.files ] || [ "$TOP_DIR" -nt __qm.files ]; then
	find $TOP_DIR -type f -name '*.qm' | \
	sed -e '
		s:'"$TOP_DIR"'::' > __qm.files
else
	echo >&2 "$PROG: Using cached __qm.files"
fi

# .mo
(
	if [ "$ALL_NAME" ]; then
		grep -F $NAME __find.files
	else
		cat __find.files
	fi
) | sed '
'"$ALL_NAME$MO"'s:\(.*/share/locale/\)\([^/@]\+\)\(@quot\|@boldquot\)\?\(@[^/]*\)\?\(/.*\.mo$\):%lang(\2\4) \1\2\3\4\5:
'"$NO_ALL_NAME$MO"'s:\(.*/share/locale/\)\([^/@]\+\)\(@quot\|@boldquot\)\?\(@[^/]*\)\?\(/.*/'"$NAME"'\.mo$\):%lang(\2\4) \1\2\3\4\5:
/^[^%]/d
s:%lang(C) ::' >> $MO_NAME

# .omf
(
	if [ "$ALL_NAME" ]; then
		grep -F $NAME __omf.files
	else
		cat __omf.files
	fi
) | sed '
'"$ALL_NAME$OMF"'s:\(.*/share/omf/[^/]\+/\)\(.*-\)\([^-]*\)\(\.omf\):%lang(\3) \1\2\3\4:
'"$NO_ALL_NAME$OMF"'s:\(.*/share/omf/'"$NAME"'/\)\(.*-\)\([^-]*\)\(\.omf\):%lang(\3) \1\2\3\4:
/^[^%]/d
s:%lang(C) ::' >> $MO_NAME

# .qm
(
	if [ "$ALL_NAME" ]; then
		grep -F $NAME __qm.files
	else
		cat __qm.files
	fi
) | sed '
'"$ALL_NAME$QM"'s:\(.*/share/locale/\)\([^/@]\+\)\(@quot\|@boldquot\)\?\(@[^/]*\)\?\(/.*\.qm$\):%lang(\2\4) \1\2\3\4\5:
'"$NO_ALL_NAME$QM"'s:\(.*/share/locale/\)\([^/@]\+\)\(@quot\|@boldquot\)\?\(@[^/]*\)\?\(/.*/'"$NAME"'\.qm$\):%lang(\2\4) \1\2\3\4\5:
/^[^%]/d
s:%lang(C) ::' >> $MO_NAME

if [ ! -f __find.dirs ] || [ "$TOP_DIR" -nt __find.dirs ]; then
	find $TOP_DIR -mindepth 1 -type d | sed 's:'"$TOP_DIR"'::' > __find.dirs
else
	echo >&2 "$PROG: Using cached __find.dirs"
fi

# gnome
(
	if [ "$ALL_NAME" ]; then
		grep -F $NAME __find.dirs
	else
		cat __find.dirs
	fi
) | sed '
'"$NO_ALL_NAME$GNOME"'s:\(.*/share/help/\)\([^/]\+\)\(/'"$NAME"'\)$:%lang(\2) \1\2\3:
'"$NO_ALL_NAME$GNOME"'s:\(.*/gnome/help/'"$NAME"'$\):%dir \1:
'"$NO_ALL_NAME$GNOME"'s:\(.*/gnome/help/'"$NAME"'/\)\([^/]\+\)$:%lang(\2) \1\2:
'"$ALL_NAME$GNOME"'s:\(.*/share/help/\)\([^/]\+\)\(/[^/]\+\)$:%lang(\2) \1\2\3:
'"$ALL_NAME$GNOME"'s:\(.*/gnome/help/[^/]\+$\):%dir \1:
'"$ALL_NAME$GNOME"'s:\(.*/gnome/help/[^/]\+/\)\([^/]\+\)$:%lang(\2) \1\2:
/^[^%]/d
s:%lang(C) ::' >> $MO_NAME

# mate
(
	if [ "$ALL_NAME" ]; then
		grep -F $NAME __find.dirs
	else
		cat __find.dirs
	fi
) | sed '
'"$NO_ALL_NAME$MATE"'s:\(.*/share/help/\)\([^/]\+\)\(/'"$NAME"'\)$:%lang(\2) \1\2\3:
'"$NO_ALL_NAME$MATE"'s:\(.*/mate/help/'"$NAME"'$\):%dir \1:
'"$NO_ALL_NAME$MATE"'s:\(.*/mate/help/'"$NAME"'/\)\([^/]\+\)$:%lang(\2) \1\2:
'"$ALL_NAME$MATE"'s:\(.*/share/help/\)\([^/]\+\)\(/[^/]\+\)$:%lang(\2) \1\2\3:
'"$ALL_NAME$MATE"'s:\(.*/mate/help/[^/]\+$\):%dir \1:
'"$ALL_NAME$MATE"'s:\(.*/mate/help/[^/]\+/\)\([^/]\+\)$:%lang(\2) \1\2:
/^[^%]/d
s:%lang(C) ::' >> $MO_NAME

# kde
(
	if [ "$ALL_NAME" ]; then
		grep -F $NAME __find.dirs
	else
		cat __find.dirs
	fi
) | sed '
'"$NO_ALL_NAME$KDE"'s:\(.*/doc/kde/HTML/\)\([^/]\+\)\(/'"$NAME"'\)$:%lang(\2) \1\2\3:
'"$ALL_NAME$KDE"'s:\(.*/doc/kde/HTML/\)\([^/]\+\)\(/[^/]\+\)$:%lang(\2) \1\2\3:
/^[^%]/d
s:%lang(C) ::' >> $MO_NAME

(
	if [ "$ALL_NAME" ]; then
		grep -F $NAME __find.dirs
	else
		cat __find.dirs
	fi
) | sed '
'"$NO_ALL_NAME$OMF"'s:\(.*/share/omf/'"$NAME"'$\):%dir \1:
'"$ALL_NAME$OMF"'s:\(.*/share/omf/[^/]\+$\):%dir \1:
/^[^%]/d
s:%lang(C) ::' >> $MO_NAME

if [ "$(grep -Ev '(^%defattr|^$)' $MO_NAME | wc -l)" -le 0 ]; then
	echo >&2 "$PROG: Error: international files not found for '$NAME'!"
	exit 1
fi

if [ "$APPEND" ]; then
	cat $MO_NAME >> $OUTPUT
	rm -f $MO_NAME
else
	mv -f $MO_NAME $OUTPUT
fi
