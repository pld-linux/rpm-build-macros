# PHP specific macro definitions.

# name of php package
%php_name		php%{?php_suffix}

# use rpmbuild -D 'php_suffix 54' to build php extension for php 5.4
# NOTE: error output must be empty. otherwise can't build pecl packages if no php*-devel is installed
%php_suffix		%{expand:%%global php_suffix %(c=$(php-config --sysconfdir 2>/dev/null) || echo '' && echo ${c#/etc/php})%%{nil}}%php_suffix

# phpXY, version always present for using current php version (in regards of php*-devel package)
%php_versuffix		%{expand:%%global php_versuffix %((IFS=.; set -- $(php-config --version); echo $1$2))%%{nil}}%php_versuffix

# php cli. version that php headers are installed for
%__php			/usr/bin/php%{php_versuffix}

%php_pear_dir		/usr/share/pear
%php_data_dir		/usr/share/php
%php_extensiondir	%{expand:%%global php_extensiondir %(php-config --extension-dir 2>/dev/null || echo ERROR)}%php_extensiondir
%php_sysconfdir		%{expand:%%global php_sysconfdir %(php-config --sysconfdir 2>/dev/null || echo ERROR)}%php_sysconfdir
%php_includedir		%{expand:%%global php_includedir %(php-config --include-dir 2>/dev/null || echo ERROR)}%php_includedir

# extract php/zend api versions
%php_major_version	%{expand:%%global php_major_version %(awk '/#define PHP_MAJOR_VERSION/{print $3}' %{php_includedir}/main/php_version.h 2>/dev/null || echo ERROR)}%php_major_version
%php_minor_version	%{expand:%%global php_minor_version %(awk '/#define PHP_MINOR_VERSION/{print $3}' %{php_includedir}/main/php_version.h 2>/dev/null || echo ERROR)}%php_minor_version
%php_api_version	%{expand:%%global php_api_version %(awk '/#define PHP_API_VERSION/{print $3}' %{php_includedir}/main/php.h 2>/dev/null || echo ERROR)}%php_api_version
%php_pdo_api_version	%{expand:%%global php_pdo_api_version %(awk '/#define PDO_DRIVER_API/{print $3}' %{php_includedir}/ext/pdo/php_pdo_driver.h 2>/dev/null || echo ERROR)}%php_pdo_api_version
%php_debug		%{expand:%%global php_debug %(awk '/#define ZEND_DEBUG/{print $3}' %{php_includedir}/main/php_config.h 2>/dev/null || echo ERROR)}%php_debug
%zend_module_api	%{expand:%%global zend_module_api %(awk '/#define ZEND_MODULE_API_NO/{print $3}' %{php_includedir}/Zend/zend_modules.h 2>/dev/null || echo ERROR)}%zend_module_api
%zend_extension_api	%{expand:%%global zend_extension_api %(awk '/#define ZEND_EXTENSION_API_NO/{print $3}' %{php_includedir}/Zend/zend_extensions.h 2>/dev/null || echo ERROR)}%zend_extension_api
%_zend_zts		%{expand:%%global _zend_zts %(Z=$(grep -sc '^#define ZTS 1' %{php_includedir}/main/php_config.h); echo ${Z:-ERROR})}%_zend_zts
# "_ts" if ZTS enabled, empty otherwise
%zend_zts		%{expand:%%global _zend_zts_%{?_zend_zts} 1}%{?_zend_zts_1:_ts}

# helper macro
%__php_api_requires() Requires: %{php_name}(%{expand:%1}) = %{expand:%{%{!?2:%{1}}%{?2}}}

# macros for public use
# for php extensions (php-pecl)
%requires_php_extension %{__php_api_requires modules_api php_api_version} \
%{__php_api_requires zend_module_api} \
%{__php_api_requires debug php_debug} \
%{__php_api_requires thread-safety _zend_zts}

# for zend extensions
%requires_zend_extension %{__php_api_requires zend_module_api} \
%{__php_api_requires zend_extension_api} \
%{__php_api_requires debug php_debug} \
%{__php_api_requires thread-safety _zend_zts}

# for php pdo modules (php-pecl-PDO_*)
%requires_php_pdo_module %{__php_api_requires PDO_API php_pdo_api_version}

# for using PHP post scripts. for PHP >= 5.0
%php_webserver_restart \
[ ! -f /etc/apache/conf.d/??_mod_php.conf ] || %service -q apache restart \
[ ! -f /etc/httpd/conf.d/??_mod_php.conf ] || %service -q httpd restart \
if [ -x /etc/rc.d/init.d/php-fcgi ]; then \
	PHP_FCGI_BINARY=; . /etc/sysconfig/php-fcgi 2>/dev/null \
	if [[ ${PHP_FCGI_BINARY:-php.fcgi} = *php.fcgi* ]]; then \
		%service -q php-fcgi restart \
	fi \
fi \
if [ -x /etc/rc.d/init.d/%{php_name}-fpm ]; then \
	%service -q %{php_name}-fpm restart \
fi \
%{nil}

# for using php post scripts. for PHP >= 4.0 && PHP < 5.0
%php4_webserver_restart \
[ ! -f /etc/apache/conf.d/??_mod_php4.conf ] || %service -q apache restart \
[ ! -f /etc/httpd/conf.d/??_mod_php4.conf ] || %service -q httpd restart \
if [ -x /etc/rc.d/init.d/php-fcgi ]; then \
	PHP_FCGI_BINARY=; . /etc/sysconfig/php-fcgi 2>/dev/null \
	if [[ ${PHP_FCGI_BINARY:-php.fcgi} = *php4.fcgi* ]]; then \
		%service -q php-fcgi restart \
	fi \
fi \
%{nil}

# PEAR install macros
# Author: Elan Ruusamäe <glen@pld-linux.org>
#
# Usage:
#	%%pear_package_setup ...
#
# -a #   - also unpack SOURCE#. for PEAR bootstrapping
# -n FMT - create builddir with FMT, instead of default %%{pearname}-%%{version}
# -z     - unpack pear package and let pear use package.xml (not tarball) for install. for PEAR bootstrapping
# -D     - pass -D to %setup (so the build dir is not removed)
# -c     - register channel from local channel.xml file
# -d     - pass -d arg to pearcmd
#
# unpack PEAR package to %%{_builddir}/FMT. package is extracted with already
# destination hierarchy. you should copy the tree to buildroot after
# patching/reorganizing with %%pear_package_install.
#
# additionally BUILDROOT is stripped from files and files are converted to UNIX
# line endings.
#
# the pear install process output is recorded to install.log, you should put it
# to %%doc for later debug or just for information.
#
# additionally additional-packages.txt is produced if it was detected that the
# package has optional dependencies. the file format is suitable of displaying
# in %%post of a package. you should put this file to %%doc. noautocompressdoc is
# automatically added for this file.


# records install.log and transforms PEAR names to PLD Linux rpm package names.
%__pear_install_log \
tee install.log \
# make post message of optional packages \
grep -E 'can optionally use|Optional feature' install.log | sed -e 's,package "pear/,package "php-pear-,g;s,^pear/,php-pear-,;s,^pear/,php-pear-,' > optional-packages.txt \
if [ -s optional-packages.txt ]; then \
	awk -F'"' '/use package/{print $2}' optional-packages.txt | sed -e "s,_,/,g;s,php-pear-, 'pear(,;s,$,.*)'," | tr -d '\\\n' > _noautoreq \
else \
	rm -f optional-packages.txt \
fi \
%{nil}

# Command invoking PEAR CLI
# Same as /usr/bin/pear, except we force GMT timezone
%__pear	%__php -doutput_buffering=1 -dopen_basedir="" -dmemory_limit=-1 -ddate.timezone=GMT /usr/share/pear/pearcmd.php

%pear_install(a:d:n:zD) \
%__pear \\\
	-c %{builddir}/pearrc \\\
	-d doc_dir=/docs \\\
	-d temp_dir=/tmp \\\
	-d php_dir=%{-c:%{builddir}/}%{php_pear_dir} \\\
	-d bin_dir=%{_bindir} \\\
	-d data_dir=%{php_pear_dir}/data \\\
	-d test_dir=%{php_pear_dir}/tests \\\
	%{-d:%(echo "%{-d*}" | awk 'BEGIN{RS=","}{printf("-d %%s \\\\\\n\\t", $1)}')} \\\
	install \\\
	--packagingroot=%{builddir} \\\
	--offline \\\
	--nodeps \\\
	%{-f:--force} \\\
	%{!-z:%{S:%{-a*}%{!-a:0}}}%{-z:$_P} > .install.log || { c=$?; cat .install.log; exit $c; }; \
	%{-c:cp -a %{builddir}/%{builddir}/%{php_pear_dir} %{builddir}/%(dirname %{php_pear_dir}); rm -rf %{builddir}/%{builddir}; } \
%{nil}

# The main macro.
# using this macro will append optional-packages.txt to the nocompressdoc list
# as it's displayed to user after package install. and adding additional gzip
# dep is just waste ;)
%pear_package_setup(a:d:n:zDc:) \
%define srcdir %{-n*}%{!-n:%{?_pearname}%{!?_pearname:%{pearname}}-%{version}} \
%define builddir %{_builddir}/%{srcdir} \
%setup -q -c -T %{-D:-D} -n %{srcdir} \
%{-z:%{__tar} zxf %{S:0}; %{-a:%{__tar} zxf %{S:%{-a*}}}} \
%{-z:_P=package2.xml; [ -f $_P ] || _P=package.xml; _N=%{srcdir}; mv $_P $_N; cd $_N} \
%{-c:%{__pear} -c pearrc config-set php_dir %{builddir}/%{php_pear_dir}; %__pear -c %{builddir}/pearrc channel-add %{-c*}} \
%pear_install \
%{-z:cd ..} \
%{__tar} --wildcards -zvxf %{S:0} package*.xml \
cat %{-z:$_N/}.install.log | %__pear_install_log \
%undos -f php,html,js,xml \
%{!?_noautocompressdoc:%global _noautocompressdoc %{nil}}%{expand:%%global _noautocompressdoc %{_noautocompressdoc} optional-packages.txt} \
%{!?_noautoprov:%global _noautoprov %{nil}}%{expand:%%global _noautoprov %{_noautoprov} 'pear(tests/.*)'} \
%{nil}

# Copies extracted PEAR package structure and PEAR registry to buildroot.
# Author: Elan Ruusamäe <glen@pld-linux.org>
%pear_package_install() \
cp -a ./%{php_pear_dir}/{.registry,*} $RPM_BUILD_ROOT%{php_pear_dir} \
# tests should not be packaged \
%{__rm} -rf $RPM_BUILD_ROOT%{php_pear_dir}/tests \
# cleanup backups \
find $RPM_BUILD_ROOT%{php_pear_dir} '(' -name '*~' -o -name '*.orig' ')' | xargs -r rm -v \
# help the developer out a little: \
if [ -f _noautoreq ]; then \
	echo "AutoReqdep detected:" \
	echo "_noautoreq $(cat _noautoreq)" \
fi \
%{nil}

# Print optional package info for pear packages
# Author: Elan Ruusamäe <glen@pld-linux.org>
# Usage:
#   %post -p <lua>
#	%%pear_package_print_optionalpackages
#
# Requirements:
# BuildRequires:	rpmbuild(macros) >= 1.571
%pear_package_print_optionalpackages \
f = io.open("%{_docdir}/%{name}-%{version}/optional-packages.txt", "r") \
if f then \
	for l in f:lines() do print(l); end \
	f:close() \
end \
%{nil}
