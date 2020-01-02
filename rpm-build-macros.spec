%define		rpm_macros_rev	1.744
%define		find_lang_rev	1.40
Summary:	PLD Linux RPM build macros
Summary(pl.UTF-8):	Makra do budowania pakietów RPM dla Linuksa PLD
Name:		rpm-build-macros
Version:	%{rpm_macros_rev}
Release:	2
License:	GPL
Group:		Development/Building
Source0:	macros.pld
Source1:	service_generator.sh
Source3:	find-lang.sh
Source4:	dokuwiki-find-lang.sh
Source5:	macros.kernel

Source10:	attr.ruby
Source11:	macros.ruby
Source12:	rubygems.rb
Source13:	gem_helper.rb

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
# macros.d/ruby
Conflicts:	rpm-build < 5.4.15-52
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

%package rubyprov
Summary:	Ruby tools, which simplify creation of RPM packages with Ruby software
Summary(pl.UTF-8):	Makra ułatwiające tworzenie pakietów RPM z programami napisanymi w Ruby
Group:		Applications/File
Requires:	%{name} = %{version}-%{release}
Requires:	ruby
Requires:	ruby-modules
Requires:	ruby-rubygems
Provides:	rpm-rubyprov
Obsoletes;	rpm-rubyprov

%description rubyprov
Ruby tools, which simplifies creation of RPM packages with Ruby
software.

%description rubyprov -l pl.UTF-8
Makra ułatwiające tworzenie pakietów RPM z programami napisanymi w
Ruby.

%prep
%setup -qcT
cp -p %{SOURCE0} .
cp -p %{SOURCE1} .
cp -p %{SOURCE5} .

%if "%{pld_release}" == "ac"
%{__sed} -i -e '/libtoolize --copy --force --install/s/ --install//' macros.pld
%patch0 -p1
%endif

%build
%{__sed} -i -e 's,{Revision},%{rpm_macros_rev},' macros.pld

rev=$(awk '/^%%rpm_build_macros/{print $2}' macros.pld)
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
install -d $RPM_BUILD_ROOT%{_usrlibrpm}/macros.d

cp -p macros.pld $RPM_BUILD_ROOT%{_usrlibrpm}/macros.build
cp -p macros.kernel $RPM_BUILD_ROOT%{_usrlibrpm}/macros.d/kernel

install -p service_generator.sh $RPM_BUILD_ROOT%{_usrlibrpm}
install -p %{SOURCE3} $RPM_BUILD_ROOT%{_usrlibrpm}/find-lang.sh
install -p %{SOURCE4} $RPM_BUILD_ROOT%{_usrlibrpm}/dokuwiki-find-lang.sh

cat %{SOURCE11} %{SOURCE10} >$RPM_BUILD_ROOT%{_usrlibrpm}/macros.d/ruby
install -p %{SOURCE12} $RPM_BUILD_ROOT%{_usrlibrpm}/rubygems.rb
install -p %{SOURCE13} $RPM_BUILD_ROOT%{_usrlibrpm}/gem_helper.rb

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%{_usrlibrpm}/macros.build
%{_usrlibrpm}/macros.d/kernel
%{_usrlibrpm}/macros.d/ruby
%attr(755,root,root) %{_usrlibrpm}/service_generator.sh
%attr(755,root,root) %{_usrlibrpm}/find-lang.sh
%attr(755,root,root) %{_usrlibrpm}/dokuwiki-find-lang.sh

%files rubyprov
%defattr(644,root,root,755)
%attr(755,root,root) %{_usrlibrpm}/gem_helper.rb
%attr(755,root,root) %{_usrlibrpm}/rubygems.rb
