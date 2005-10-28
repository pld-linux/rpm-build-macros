# NOTE:
# - AC-branch is TAG. please move the tag if rebuild needed:
%if 0
cvs up -A rpm-macros.spec
cvs tag -F AC-branch rpm-macros.spec
./builder -r AC-branch -bb rpm-macros.spec
%endif
# TODO
# - move macros.pld to /usr/lib/rpm, but first need to change rpmmrc
#   for it to search the macrofile from there.
# - commit debuginfo.patch to rpm.macros
%define	rpm_macros_rev	1.253
Summary:	PLD Linux RPM Macros
Summary(pl):	Makra RPM dla Linuksa PLD
Name:		rpm-build-macros
Version:	%{rpm_macros_rev}
Release:	1.3
License:	GPL
Group:		Base
Source0:	rpm.macros
Requires:	rpm-build
Provides:	rpmbuild(macros) = %{rpm_macros_rev}
Obsoletes:	rpm-macros
BuildArch:	noarch
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

%define		_rpmlibdir /usr/lib/rpm

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
install -d $RPM_BUILD_ROOT%{_rpmlibdir}
cp %{SOURCE0} $RPM_BUILD_ROOT%{_rpmlibdir}/macros.build

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%{_rpmlibdir}/*
