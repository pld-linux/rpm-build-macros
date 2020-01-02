%__java_requires	env RPM_BUILD_ROOT=%{buildroot} MIN_CLASSDATAVERSION=%{?java_min_classdataversion} %{_rpmhome}/java-find-requires
%__java_magic		^Java .*
%__java_path		\\.(jar|class)$
