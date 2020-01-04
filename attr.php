%__php_provides		%{_rpmconfigdir}/php.prov
# define 'php_req_new' in ~/.rpmmacros to use php version of req finder
%__php_requires		env PHP_MIN_VERSION=%{?php_min_version} %{_rpmconfigdir}/php.req%{?php_req_new:.php}
%__php_magic		^PHP script.*
%__php_path		\\.php$
