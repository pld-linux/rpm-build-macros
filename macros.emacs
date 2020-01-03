# (X)emacs support
%___emacs_lispdir_helper -batch -q -eval '(while load-path (princ (concat (car load-path) "\\n")) (setq load-path (cdr load-path)))' 2> /dev/null|sed -n '/\\(.*\\/x\\?emacs\\/site-lisp\\)\\/\\?$/{s,,\\1,p;q;}'
%_emacs_lispdir %{expand:%%global _emacs_lispdir %(Z=$(emacs %___emacs_lispdir_helper); echo ${Z:-ERROR})}%_emacs_lispdir
%_xemacs_lispdir %{expand:%%global _xemacs_lispdir %(Z=$(xemacs %___emacs_lispdir_helper); echo ${Z:-ERROR})}%_xemacs_lispdir
