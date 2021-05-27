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

;; TODO: finish path.el first


;; TODO: here

(defun iii:load (path-root &rest feature)
  "Load a file relative to PATH-ROOT based on FEATURE list of keywords/symbols.

The zeroith element in FEATURES is assumed to be represented by PATH-ROOT.
E.g. (iii:load \"/path/to/imp\" :imp 'provide)
  Will try to load: \"/path/to/imp/provide.el\"

If nothing is provided for FEATURE except a single keyword/symbol, it will use
PATH-ROOT as-is.
E.g. (iii:load \"/path/to/imp/init.el\" :imp)"
  ;; TODO: 'load-all' functionality?
  (let* ((normal (apply #'iii:string:normalize names))
         (name (apply #'iii:load:name normal))
         (path (apply #'iii:path:get normal)))
    (condition-case-unless-debug e
        (let (file-name-handler-alist)
          ;(load path nil))
          (load path nil 'nomessage))
    (error "mis fail loading: %s (%S); error: %S" path name e))))
;; (imp:load 'test 'something)


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
  (unless (apply #'iii:provided? names)
    (apply #'iii:load names)))
;; (imp:require 'test 'this)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :imp 'require)
(provide 'imp:require)
