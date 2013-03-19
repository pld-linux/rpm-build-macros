%define		rpm_macros_rev	1.655
%define		find_lang_rev	1.36
Summary:	PLD Linux RPM build macros
Summary(pl.UTF-8):	Makra do budowania pakietów RPM dla Linuksa PLD
Name:		rpm-build-macros
Version:	%{rpm_macros_rev}
Release:	2
License:	GPL
Group:		Development/Building
Source0:	rpm.macros
Source1:	service_generator.sh
Source3:	find-lang.sh
Source4:	dokuwiki-find-lang.sh
Patch0:		disable-systemd.patch
#Patchx: %{name}-pydebuginfo.patch
BuildRequires:	rpm >= 4.4.9-56
BuildRequires:	sed >= 4.0
Requires:	findutils >= 1:4.2.26
Provides:	rpmbuild(find_lang) = %{find_lang_rev}
Provides:	rpmbuild(macros) = %{rpm_macros_rev}
Obsoletes:	rpm-macros
# rm: option `--interactive' doesn't allow an argument
Conflicts:	coreutils < 6.9
Conflicts:	gettext-devel < 0.11
# tmpdir/_tmppath macros problems; optcppflags missing
Conflicts:	rpm < 4.4.9-72
# php-config --sysconfdir
Conflicts:	php-devel < 4:5.2.0-3
Conflicts:	php4-devel < 3:4.4.4-10
# sysconfig module with proper 'purelib' path
Conflicts:	python3 < 1:3.2.1-3
%if "%{pld_release}" != "ac"
# libtool --install
Conflicts:	libtool < 2:2.2
%endif
BuildArch:	noarch
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

# redefine to bootstrap
%define		_usrlibrpm %{_prefix}/lib/rpm

%description
This package contains rpm build macros for PLD Linux.

%description -l pl.UTF-8
Ten pakiet zawiera makra rpm-a do budowania pakietów dla Linuksa PLD.

%prep
%setup -qcT
cp -p %{SOURCE0} .
cp -p %{SOURCE1} .

%if "%{pld_release}" == "ac"
%{__sed} -i -e '/libtoolize --copy --force --install/s/ --install//' rpm.macros
%patch0 -p1
%endif

%build
%{__sed} -i -e 's,{Revision},%{rpm_macros_rev},' rpm.macros

rev=$(awk '/^%%rpm_build_macros/{print $2}' rpm.macros)
if [ "$rev" != "%rpm_macros_rev" ]; then
	: Update rpm_macros_rev define to $rev, and retry
	exit 1
fi
rev=$(awk -F= '/^VERSION/{print $2}' %{SOURCE3})
if [ "$rev" != "%find_lang_rev" ]; then
	: Update find_lang_rev define to $rev, and retry
	exit 1
fi

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT%{_usrlibrpm}
cp -a rpm.macros $RPM_BUILD_ROOT%{_usrlibrpm}/macros.build
install -p service_generator.sh $RPM_BUILD_ROOT%{_usrlibrpm}
install -p %{SOURCE3} $RPM_BUILD_ROOT%{_usrlibrpm}/find-lang.sh
install -p %{SOURCE4} $RPM_BUILD_ROOT%{_usrlibrpm}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%{_usrlibrpm}/macros.build
%attr(755,root,root) %{_usrlibrpm}/service_generator.sh
%attr(755,root,root) %{_usrlibrpm}/find-lang.sh
%attr(755,root,root) %{_usrlibrpm}/dokuwiki-find-lang.sh
