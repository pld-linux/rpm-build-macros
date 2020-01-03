# Perl specific macro definitions.

%__perl			/usr/bin/perl

%perl_privlib		%{expand:%%global perl_privlib %(eval $(%{__perl} -V:installprivlib 2>/dev/null); echo ${installprivlib:-ERROR})}%perl_privlib
%perl_archlib		%{expand:%%global perl_archlib %(eval $(%{__perl} -V:installarchlib 2>/dev/null); echo ${installarchlib:-ERROR})}%perl_archlib
%perl_vendorlib		%{expand:%%global perl_vendorlib %(eval $(%{__perl} -V:installvendorlib 2>/dev/null); echo ${installvendorlib:-ERROR})}%perl_vendorlib
%perl_vendorarch	%{expand:%%global perl_vendorarch %(eval $(%{__perl} -V:installvendorarch 2>/dev/null); echo ${installvendorarch:-ERROR})}%perl_vendorarch
%perl_sitelib		%{expand:%%global perl_sitelib %(eval $(%{__perl} -V:installsitelib 2>/dev/null); echo ${installsitelib:-ERROR})}%perl_sitelib
%perl_sitearch		%{expand:%%global perl_sitearch %(eval $(%{__perl} -V:installsitearch 2>/dev/null); echo ${installsitearch:-ERROR})}%perl_sitearch
