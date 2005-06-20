# NOTE
# - AC-branch is TAG. please move the tag if rebuild needed:
#  $ cvs tag -F AC-branch rpm-macros.spec
# TODO
# - make rpm actually search for this rpm.macros file
%define	rpm_macros_rev	1.223
Summary:	PLD Linux RPM Macros
Summary(pl):	Makra RPM dla Linuksa PLD
Name:		rpm-macros
Version:	%{rpm_macros_rev}
Release:	0.4
License:	GPL
Group:		Base
Source0:	rpm.macros
Requires:	rpm-build
Provides:	rpmbuild(macros) = %{rpm_macros_rev}
Conflicts:	rpm < 4.4.1
BuildArch:	noarch
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

%description
This package contains rpm macros for PLD Linux.

Use this package to get newer rpm macros than rpm-build provides
(perhaps this package will be separated in the future).

%description -l pl
Ten pakiet zawiera makra rpm-a dla Linuksa PLD.

Mo¿na u¿yæ tego pakietu aby uzyskaæ nowsze makra rpm-a ni¿ dostarcza
rpm-build (byæ mo¿e ten pakiet zostanie w przysz³o¶ci wydzielony).

%prep

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT%{_sysconfdir}/rpm
sed -e '
# truncate until %%_topdir macro
1,/^%%_topdir/d
' %{SOURCE0} > $RPM_BUILD_ROOT%{_sysconfdir}/rpm/macros.pld

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%config %verify(not md5 mtime size) %{_sysconfdir}/rpm/*
