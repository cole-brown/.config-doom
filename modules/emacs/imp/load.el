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

(defun int<imp>:load:file (filepath)
  "Loads FILEPATH.

Lexically clears `file-name-handler-alist' for loading.

Calls `load' with errors allowed and `nomessage' set.

Returns result of `load' or signals error."
  (let ((func.name "int<imp>:load:file"))
    (int<imp>:debug func.name
                    "load filepath '%s'..."
                    filepath)

    (condition-case-unless-debug err
        ;; Set `file-name-handler-alist' to nil so we can `load' without it,
        ;; then load and save result for return value.
        (let* (file-name-handler-alist
               (loaded (load filepath nil 'nomessage)))
          (int<imp>:debug func.name
                          "loaded '%s': %S"
                          filepath
                          loaded)
          loaded)
      (error (int<imp>:error "int<imp>:load:file"
                             "imp fail to load filepath: %s\n  - error: %S"
                             filepath
                             err)))))


;; TODO: Rename `int<imp>:load:feature'?
;; TODO: Delete entirely and just use newer `imp:feature:at' stuff?
;;         - Or rework into `int<imp>:load:all'?
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
         (int<imp>:load:file (int<imp>:path:get (cons feature:base feature))))

        ;; Fallback: Try to let emacs require it:
        (t
         (require (int<imp>:feature:normalize:imp->emacs feature)
                 ;; TODO:load: guess at a file/path based on 'feature:base/feature-0/...'?
                 nil
                 'noerror))))
;; (int<imp>:load :imp 'something)
;; (int<imp>:load :config 'spy 'system 'config)


;; TODO:test: Make unit test.
(defun int<imp>:load:paths (feature path:root paths:relative)
  "Load PATHS:RELATIVE files (list of path strings relative to PATH:ROOT path string).

Returns or'd result of loading feature's files if feature is found;
returns non-nil if feature's files were all loaded successfully.

FEATURE is only for `imp:timing' use."
  (let ((func.name "int<imp>:load:paths")
        (load-result t))
    (int<imp>:debug func.name
                    '("Inputs:\n"
                      "  feature:        %S\n"
                      "  path:root:      %s\n"
                      "  paths:relative: %S")
                    feature
                    path:root
                    paths:relative)

    ;; Get full path and load file.
    ;; Return `load-result' when done with loading.
    ;; TODO: map/reduce instead of dolist?
    (dolist (relative paths:relative load-result)
      (let ((path:absolute (int<imp>:path:normalize path:root relative :file:load)))
        (int<imp>:debug func.name
                        '("loading:\n"
                          "  root:             %s\n"
                          "  relative:         %s\n"
                          "-> `path:absolute': %s")
                        path:root
                        relative
                        path:absolute)
        (setq load-result (and load-result
                              ;; Time this load if timing is enabled.
                              (imp:timing
                                  feature
                                  (int<imp>:path:filename path:absolute)
                                  (int<imp>:path:parent   path:absolute)
                                (int<imp>:load:file path:absolute))))))))


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

(defun int<imp>:load:init ()
  "Provide the imp:load feature."
  (imp:provide:with-emacs :imp 'load))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
