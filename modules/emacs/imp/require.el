;;; emacs/imp/require.el -*- lexical-binding: t; -*-


;; imp requirements:
;;   - :imp 'debug
;;   - :imp 'error
;;   - :imp 'path
;;   - :imp 'provide


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------


;;------------------------------------------------------------------------------
;; Private Functions
;;------------------------------------------------------------------------------

;; TODO: a load timing feature?
;;   - One in `iii:load' that will:
;;     1. start timer, output: "loading xxx..."?
;;     2. stop timer, output:  "└─yy.zzz seconds"
;;     3. Look nice when cascading?
;;        "loading xxx..."
;;        "├─loading yyy..."
;;        "│ └─cc.dd seconds"
;;        "└─aa.bb seconds"
;;     4. Output to some buffer named by defcustom (default "*Messages*").
;;  - One or two stand-alone, external-api-named funcs (that `iii:load' calls?).
;;  - An easy way to defadvice-wrap Emacs' `load' in the timing thing.


;; TODO: finish path.el first


;; TODO: here

(defun iii:load (root &rest feature)
  "Load a file relative to ROOT based on FEATURE list of keywords/symbols.

ROOT must be a keyword which exists in `imp:path:roots' (set via the
`imp:path:root'function).

E.g. (iii:load :imp 'provide)
  Will try to load: \"/path/to/imp-root/provide.el\""
  ;; TODO: 'load-all' functionality?
  (let* ((path (iii:path:get (cons root feature))))
    (condition-case-unless-debug err
        (let (file-name-handler-alist)
          (load path nil 'nomessage))
      (error "mis fail loading %S via path: %S\n  - error: %S"
             (cons root features)
             path
             err))))
;; (iii:load :imp 'something)


;;------------------------------------------------------------------------------
;; Public API: Require
;;------------------------------------------------------------------------------


(defun imp:require (root &rest names)
  "Loads file(s) indicated by NAMES from ROOT keyword if not already loaded.

Examples:
  (imp:root :mis \"path/to/mis\")

  To require/load \"mis/code/comment.el[c]\":
    (imp:load :mis 'code 'comment)

  To require/load \"mis/code/*.el[c]\":
    (imp:load :mis 'code)"
  ;; TODO: the load-all functionality
  (unless (apply #'imp:provided? root names)
    (apply #'iii:load root names)))
;; (imp:require 'test 'this)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :imp 'require)
