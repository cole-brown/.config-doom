;;; emacs/imp/require.el -*- lexical-binding: t; -*-


;; imp requirements:
;;   - :imp 'error
;;   - :imp 'path
;;   - :imp 'provide


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------


;;------------------------------------------------------------------------------
;; Load, Require, Provide
;;------------------------------------------------------------------------------

(defun iii:load (keyword &rest names)
  "Load a file relative to `iii:path:root' based on root KEYWORD and
NAMES strings/symbols.

This is for loading done internally in mis."
  ;; TODO: the load-all functionality
  (let* ((normal (apply #'iii:string:normalize names))
         (name (apply #'iii:load:name normal))
         (path (apply #'iii:path:get normal)))
    (condition-case-unless-debug e
        (let (file-name-handler-alist)
          ;(load path nil))
          (load path nil 'nomessage))
    (error "mis fail loading: %s (%S); error: %S" path name e))))
;; (imp:load 'test 'something)


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
