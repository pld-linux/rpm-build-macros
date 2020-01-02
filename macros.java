# vim:ts=4 sw=4 noet ft=spec
#
# Java macros. based on jpackage macros.java
#
# Import packaging conventions from jpackage.org (prefixed with _
# to avoid name collisions).
#
%_javadir		%{_datadir}/java
%_javadocdir		%{_datadir}/javadoc

# Root directory where all Java VMs/SDK/JREs are installed.
%_jvmdir		%{_libdir}/jvm

# Root directory where all Java VMs/SDK/JREs expose their jars
%_jvmjardir		%{_libdir}/jvm-exports

# Root directory for all Java VM/SDK/JRE's private things.
%_jvmprivdir		%{_libdir}/jvm-private

# Root directory for all architecture dependent parts of Java VM/SDK/JRE's
%_jvmlibdir		%{_libdir}/jvm

# Root directory for all architecture independent parts of Java VM/SDK/JRE's
%_jvmdatadir		%{_datadir}/jvm

# Root directory for all configurations parts of Java VM/SDK/JRE's
%_jvmsysconfdir		%{_sysconfdir}/jvm

# Root directory for all common architecture dependent parts of Java VM/SDK/JRE's
%_jvmcommonlibdir	%{_libdir}/jvm-common

# Root directory for all common architecture independent parts of Java VM/SDK/JRE's
%_jvmcommondatadir	%{_datadir}/jvm-common

# Root directory for all common configurations parts of Java VM/SDK/JRE's
%_jvmcommonsysconfdir	%{_sysconfdir}/jvm-common

# Directory where arch-specific (JNI) version-independent jars are installed.
%_jnidir		%{_libdir}/java


# JDK selection. Set this to name of the JDK implementation to use
# insead of the system default
#%use_jdk		icedtea6

# expands to the value with right jdk for BuildRequires header
# 'jdk' if %%use_jdk is not defined,  jdk(%%use_jdk) otherwise
# The requirement will not replace current 'default' JDK
%required_jdk	jdk%{?use_jdk:(%{use_jdk})}

%buildrequires_jdk BuildRequires: %required_jdk

%java_home	%{expand:%%global java_home %([ -f %{_javadir}-utils/java-functions ] || { echo ERROR; exit 0; }; %{!?use_jdk:unset JAVA_HOME; . %{_javadir}-utils/java-functions; set_jvm}%{?use_jdk:JAVA_HOME=%{_jvmdir}/%{use_jdk}}; echo ${JAVA_HOME:-ERROR})}%java_home

%_javasrcdir	%{_usrsrc}/java

%ant		JAVA_HOME=%{java_home} CLASSPATH=$CLASSPATH ant
%jar		%{java_home}/bin/jar
%java		%{expand:%%global java %([ -f %{_javadir}-utils/java-functions ] || { echo ERROR; exit 0; }; %{!?use_jdk:unset JAVACMD; . %{_javadir}-utils/java-functions; set_javacmd}%{?use_jdk:JAVACMD=%{java_home}/bin/java}; echo $JAVACMD)}%java
%javac		%{java_home}/bin/javac
%javadoc	%{java_home}/bin/javadoc

%add_jvm_extension	JAVA_LIBDIR=%{buildroot}/%{_javadir}	%{_bindir}/jvmjar -l

%jpackage_script() \
install -d $RPM_BUILD_ROOT%{_bindir}\
cat > $RPM_BUILD_ROOT%{_bindir}/%5 << 'EOF' \
#!/bin/sh\
#\
# %{name} script\
# JPackage Project <http://www.jpackage.org/>\
\
# Source functions library\
. %{_javadir}-utils/java-functions\
\
# Source system prefs\
if [ -f %{_sysconfdir}/java/%{name}.conf ]; then\
      . %{_sysconfdir}/java/%{name}.conf\
fi\
\
# Source user prefs\
if [ -f $HOME/.%{name}rc ]; then\
      . $HOME/.%{name}rc\
fi\
\
# Configuration\
MAIN_CLASS=%1\
BASE_FLAGS=%2\
BASE_OPTIONS=%3\
BASE_JARS="%(echo %4 | tr ':' ' ')"\
\
# Set parameters\
set_jvm\
set_classpath $BASE_JARS\
set_flags $BASE_FLAGS\
set_options $BASE_OPTIONS\
\
# Let's start\
run "$@"\
EOF

# jpackage 1.7
# Directory for maven depmaps
#
%_mavendepmapdir /etc/maven
%_mavendepmapfragdir /etc/maven/fragments

#
# add_to_depmap adds an entry to the depmap. The arguments are:
#
# %1 the original groupid
# %2 the original artifact id
# %3 the version
# %4 the new groupid
# %5 the new artifactid
#

%add_to_maven_depmap() \
install -dm 755 $RPM_BUILD_ROOT/%{_mavendepmapfragdir}\
cat >>$RPM_BUILD_ROOT/%{_mavendepmapfragdir}/%{name}<< EOF\
<dependency>\
    <maven>\
        <groupId>%1</groupId>\
        <artifactId>%2</artifactId>\
        <version>%3</version>\
    </maven>\
    <jpp>\
        <groupId>%4</groupId>\
        <artifactId>%5</artifactId>\
        <version>%3</version>\
    </jpp>\
</dependency>\
\
EOF\
%{nil}

#==============================================================================
#
# update_maven_depmap updates the main maven depmap
#
%update_maven_depmap() \
echo -e "<dependencies>\\n" > %{_mavendepmapdir}/maven2-depmap.xml\
if [ -d %{_mavendepmapfragdir} ] && [ -n "`find %{_mavendepmapfragdir} -type f`" ]; then\
cat %{_mavendepmapfragdir}/* >> %{_mavendepmapdir}/maven2-depmap.xml\
fi\
echo -e "</dependencies>\\n" >> %{_mavendepmapdir}/maven2-depmap.xml

# JAVA macros specific for PLD

# Directory for tomcat context configuration files
%_tomcatconfdir	/etc/tomcat/Catalina/localhost

# Tomcat cache path
%_tomcatcachedir %{_sharedstatedir}/tomcat/work/Catalina/localhost

# Clear tomcat cache
# Author: Paweł Zuzelski <pawelz@pld-linux.org>
#
# Usage:
# %%tomcat_clear_cache appname
#
# Call this script in %postun scriptlet. It will remove compiled jsps related to
# given app.
#
%tomcat_clear_cache() %{!?1:ERROR}%{?2:ERROR} %{__rm} -rf %{_tomcatcachedir}/%1
