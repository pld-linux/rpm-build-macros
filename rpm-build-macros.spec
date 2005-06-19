# TODO
# - contains unparsed macros:
#  %__id        @__ID@
#  %__chown_Rhf           @__CHOWN_RHF@
#  %__chgrp_Rhf           @__CHGRP_RHF@
%define	rpm_macros_rev	1.223
Summary:	PLD Linux RPM Macros
Name:		rpm-macros
Version:	0.1
Release:	0.1
License:	GPL
Group:		Base
Source0:	rpm.macros
Provides:	rpmbuild(macros) = %{rpm_macros_rev}
BuildArch:	noarch
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

%description
This package contains rpm macros for PLD Linux.

Use this package to get newer rpm macros than rpm-build provides
(perhaps this package will be separated in the future).

%prep

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT%{_sysconfdir}/rpm
install %{SOURCE0} $RPM_BUILD_ROOT%{_sysconfdir}/rpm/rpm.macros

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/rpm/rpm.macros
