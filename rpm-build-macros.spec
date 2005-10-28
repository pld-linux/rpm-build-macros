# NOTE:
# - AC-branch is TAG. please move the tag if rebuild needed:
%if 0
cvs up -A rpm-macros.spec
cvs tag -F AC-branch rpm-macros.spec
./builder -r AC-branch -bb rpm-macros.spec
%endif
# TODO
# - update -pl
%define	rpm_macros_rev	1.254
Summary:	PLD Linux RPM build macros
Summary(pl):	Makra RPM dla Linuksa PLD
Name:		rpm-build-macros
Version:	%{rpm_macros_rev}
Release:	1
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
This package contains rpm build macros for PLD Linux.

%description -l pl
Ten pakiet zawiera makra rpm-a dla Linuksa PLD.

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
