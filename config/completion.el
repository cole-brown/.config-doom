;;; config/completion.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Company
;;------------------------------------------------------------------------------

(after! company

  (customize-set-variable 'company-dabbrev-ignore-case t
                          "Ignore case of typed text for completion candidates.")

  ;; There's more for trying to get dabbrev to give proper/expect case results back...
  ;; But it seems to be set up right as is right now?
  ;;
  ;; dabbrev-case-replace
  ;; dabbrev-case-distinction
  ;; dabbrev-case-fold-search <- looks at case-fold-search currently?
  ;; case-fold-search <- is `t'
  )


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'completion)
