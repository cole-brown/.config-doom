;;; spy/lisp/+types.el -*- lexical-binding: t; -*-



;;------------------------------------------------------------------------------
;; Imports
;;------------------------------------------------------------------------------


;;------------------------------------------------------------------------------
;; Type checking
;;------------------------------------------------------------------------------


(defun sss:lisp/cons? (var)
  "Apparently lists qualify as conses so... fucking lisp, yeah?
...and I can't `listp' or `length' a cons because it's not a list...?!?!

Jesus fuck lisp. I just want to check for dotted-pair conses...

https://emacs.stackexchange.com/questions/10489/predicate-function-for-dotted-pairs
"
  (and (cdr var) (atom (cdr var))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'lisp 'types)
