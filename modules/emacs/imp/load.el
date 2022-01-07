;;; emacs/imp/load.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                               Load Files                               ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                    Load with, or without, timing info.
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Internal Load Functions
;;------------------------------------------------------------------------------

(defun int<imp>:load (feature:base &rest feature)
  "Load a file relative to FEATURE:BASE based on FEATURE list of keywords/symbols.

FEATURE:BASE must be a keyword which exists in `imp:path:roots' (set via the
`imp:path:root'function).

E.g. (int<imp>:load :imp 'provide)
  Will try to load: \"/path/to/imp-root/provide.el\"

Returns non-nil if loaded."
  ;; TODO:load: 'load-all' functionality?

  (cond ((apply #'imp:provided? feature:base feature)
         t)

        ;; Not loaded, but we know where to find it?
        ((int<imp>:path:root/contains? feature:base)
         ;; imp knows about this - let's try to load it.
         (let* ((path (int<imp>:path:get (cons feature:base feature))))
           (condition-case-unless-debug err
               (let (file-name-handler-alist)
                 (load path nil 'nomessage))

             (int<imp>:error "int<imp>:load"
                        "imp fail to load %S via path: %S\n  - error: %S"
                        (cons feature:base features)
                        path
                        err))))

        ;; Fallback: Try to let emacs require it:
        (t
         (require (int<imp>:feature:normalize:imp->emacs feature)
                 ;; TODO:load: guess at a file/path based on 'feature:base/feature-0/...'?
                 nil
                 'noerror))))
;; (int<imp>:load :imp 'something)
;; (int<imp>:load :config 'spy 'system 'config)


;;------------------------------------------------------------------------------
;; Load API
;;------------------------------------------------------------------------------

;; TODO: How do I get to the feature name when it's at the end of the file? >.<
;;   - Just loading message from the filename instead?


;; Based off of Doom's `load!' macro.
(defmacro imp:load (filename &optional path no-error)
  "Load a file relative to the current executing file (`load-file-name').

FILENAME is either a file path string or a form that should evaluate to such a
string at run time. When FILENAME is a relative path and PATH is nil, this looks
for FILENAME relative to the 'current file' (see below).

PATH is where to look for the file (a string representing a directory path).
If omitted, the lookup is relative to either `load-file-name',
`byte-compile-current-file' or `buffer-file-name' (checked in that order).

If NO-ERROR is non-nil, don't throw an error if the file doesn't exist."
  (let* ((path (or path
                   (int<imp>:path:current:dir)
                   (int<imp>:error "imp:load"
                                   "Could not determine path to look in for: '%s'"
                                   filename)))
         (file (if path
                   `(expand-file-name ,filename ,path)
                 filename)))
    (let (file-name-handler-alist)
      (load ,file ,no-error 'nomessage))))



;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :imp 'require)
