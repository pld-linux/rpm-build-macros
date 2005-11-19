%define	rpm_macros_rev	1.263
Summary:	PLD Linux RPM build macros
Summary(pl):	Makra do budowania pakietów RPM dla Linuksa PLD
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
Ten pakiet zawiera makra rpm-a do budowania pakietów dla Linuksa PLD.

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
