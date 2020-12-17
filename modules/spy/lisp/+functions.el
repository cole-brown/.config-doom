;;; spy/lisp/+functions.el -*- lexical-binding: t; -*-



;;------------------------------------------------------------------------------
;; Imports
;;------------------------------------------------------------------------------

;;(require 'subr-x)

;; Don't rely on too much from `:spy'. This should be low-level stuff for use
;; by other `:spy' code.
;; (spy/require :spy 'jerky)
;; (spy/require :spy 'buffer 'point)
;; (spy/require :spy 'datetime 'format)


;;------------------------------------------------------------------------------
;; Imports
;;------------------------------------------------------------------------------

(defun spy/lisp/func.args (args &rest claims)
  "Expects ARGS to be a list of:
  - Some args.
  - Followed by some keyword args.

That is, ARGS should be something like:
'((list of args) \"whatever\" ... et al :k0 v0 :k1 v1 ... :kn vn)

CLAIMS should be keywords that the caller expects. It will be
flattened to a single list of keywords to look for.

Splits ARGS list into the args and the keyword args, where
`:k0' to `:kn' are keywords in CLAIMS.

Once any of the keyword args in CLAIMS is found, that and the
rest of ARGS are assumed to be the keyword args. Everything
before will be the return args, and that keyword and everything
after will be the returned keyword args.

So this:
  '((list of args) \"whatever\" ... et al :k0 v0 :k1 v1 ... :kn vn)
Becomes this:
  '(((list of args) \"whatever\" ... et al)
    (:k0 v0 :k1 v1 ... :kn vn))

It's sort of like a function signature of:
  '&rest args &keys k0 k1 ... kn'

Just make your function like this:
  (defun spy/example (&rest args)
    ...
    (-let*/-let (((arg-list kw-list) (spy/lisp/func.args args
                                                         :jeff :zort :vogon)))
    ...

Returns a list of lists:
  (leading-args kwargs)
"
  (let ((leading-args nil)
        (rest-as-keywords nil)
        (keywords nil)
        (claims (-flatten claims)))
    ;; Sort args into args/kwargs.
    (dolist (arg args)
      ;; Once we hit the first keyword arg, the rest are always all keywords.
      (if (not (or rest-as-keywords
                   (memq arg claims)))
        ;; Still in the args.
        (push arg leading-args)

        ;; Rest are keywords.
        (setq rest-as-keywords t)
        (push arg keywords)))

    ;; Done processing list, but our lists to return are backwords right now.
    (list (nreverse leading-args) (nreverse keywords))))
;; (spy/lisp/func.args '(jeff jefferson :namespace :work) :namespace)
