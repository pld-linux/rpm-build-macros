# TCL specific macro definitions.

%__tclsh	/usr/bin/tclsh

%tcl_version	%{expand:%%global tcl_version %(echo 'puts $tcl_version' | %{__tclsh})}%tcl_version
%tcl_sitearch	%{_libdir}/tcl%{tcl_version}
%tcl_sitelib	%{_datadir}/tcl%{tcl_version}
