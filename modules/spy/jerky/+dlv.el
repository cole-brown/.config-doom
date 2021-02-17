;;; spy/jerky/+dlv.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Jerky Directory Local Variables
;;------------------------------------------------------------------------------

(require 's)
(require 'dash)


;;------------------------------------------------------------------------------
;; Auto-Namespacing
;;------------------------------------------------------------------------------

;; (defconst jerky//dlv/var.prefix "jerky//dlv//"
;;   "Jerky's dir-local variables made via `jerky/dlv.set' use this as their prefix.")


;; (defconst jerky//dlv/var.format (format "%s%%s" jerky//dlv/var.prefix)
;;   "Jerky's dir-local variables made via `jerky/dlv.set' use this format.")


;;------------------------------------------------------------------------------
;; Auto-Namespacing
;;------------------------------------------------------------------------------

(defun jerky//dlv/verify.dir (dir &optional quiet)
  "Verify DIR is valid for `jerky/dlv.set/<...>'.

If QUIET is not nil, signals error. Else returns nil on error.
Returns t on success.
"
  (cond ((not (file-name-absolute-p dir))
         (if quiet
             nil
           (error "%s: Directory path must be absolute. %s"
                  "jerky//dlv/verify.dir" dir)))
        ((not (directory-name-p dir))
         (if quiet
             nil
           (error "%s: Path must be a directory path (add '/'?). %s"
                  "jerky//dlv/verify.dir" dir)))
        ;; ((not (file-exists-p dir))
        ;;  (if quiet
        ;;      nil
        ;;    (error "%s: Directory must exist. %s"
        ;;           "jerky//dlv/verify.dir" dir)))

        ;; Ok; errors all checked.
        (t
         t)))
;; Bad:
;; (jerky//dlv/verify.dir "relative/path/file")
;; (jerky//dlv/verify.dir "c:/absolute/path/file")
;; (jerky//dlv/verify.dir "relative/path/")
;; (jerky//dlv/verify.dir "c:/absolute/path/")
;; Good:
;; (jerky//dlv/verify.dir user-emacs-directory)


(defun jerky//dlv/verify.namespace (namespace &optional quiet)
  "Verify NAMESPACE is valid for `jerky/dlv.set/<...>'.

That is, it verifies the namespace exists.

If QUIET is not nil, signals error. Else returns nil on error.
Returns t on success.
"
  (cond ((not (jerky//namespace/valid namespace quiet))
         ;; `jerky//namespace/valid' will raise the error if we are not quiet.
         nil)

        ((not (jerky/namespace/has namespace))
         (if quiet
             nil
           (error "%s: Namespace does not exist: %s"
                  "jerky//dlv/verify.namespace" namespace)))

        ;; Ok; errors checked.
        (t
         t)))
;; (jerky//dlv/verify.namespace 'not-keyword)
;; (jerky//dlv/verify.namespace :ns-non-existant)
;; (jerky//dlv/verify.namespace :work)


(defun jerky//dlv/verify.variable (namespace var &optional quiet)
  "Verify VAR is valid for `jerky/dlv.set/<...>'.

That is, it verifies the variable VAR exists for a NAMESPACE.

If QUIET is not nil, signals error. Else returns nil on error.
Returns t on success.
"
  (cond ((not (jerky/has var :namespace namespace))
         (if quiet
             nil
           (error "%s: Jerky variable does not exist for namespace. %s %s"
                  "jerky//dlv/verify.variable" namespace var)))

        ;; Ok; errors checked.
        (t
         t)))
;; (jerky//dlv/verify.variable nil "secret/jeff" )
;; (jerky//dlv/verify.variable nil "secret/jeff2")
;; (jerky//dlv/verify.variable nil "secret/jeff3")


(defun jerky//dlv/dlv.key (namespace class &optional symbol quiet)
  "Create a jerky key from inputs for using in jDLV.

CLASS should be the name of a symbol for creating the
`dir-locals-set-class-variables' or nil.

If CLASS is non-nil, this returns:
  (jerky//key/normalize 'dlv NAMESPACE CLASS)
Else, this returns:
  (jerky//key/normalize 'dlv NAMESPACE SYMBOL)

If QUIET is non-nil, return nil instead of raise error signal.
"
  (if (null class)
      (if (or (null namespace) (null symbol))
          (if quiet
              nil
            (error (concat "Null `class' param so must have `namespace' "
                           "and `symbol'. Got: class: %S, namespace %S, "
                           "symbol %S")
                   class namespace symbol))
        (jerky//key/normalize (list :dlv namespace symbol) quiet))
    (jerky//key/normalize (list :dlv namespace class) quiet)))
;; (jerky//dlv/dlv.key :work 'org-journal)
;; (jerky//dlv/dlv.key :work nil 'org-journal-dir)


(defun jerky//dlv/var.create (var value &optional quiet)
  "Create the key/value pair from VAR and VALUE for a variable for the
directory local variables list.

If QUIET is not nil, signals error. Else returns nil on error.
"
  ;; Sanity
  (if (not (symbolp var))
      (if quiet
          nil
        (error "%s: `var' must be a symbol! %S" "jerky//dlv/var.create" var))
    ;; `jerky//dlv/var.name/dlv.create' will verify var exists in jerky.
    ;;(cons (jerky//dlv/var.name/dlv.create var namespace quiet)
    (cons var
          value)))
;; (jerky//dlv/var.create "jeff/var" '(:ns-jeff 42 "docstr"))
;; (jerky//dlv/var.create 'jeff/var '(:ns-jeff 42 "docstr"))
;; (let ((var '("jeff/var" :ns-jeff 42 "docstr"))) (cdr var))


(defun jerky//dlv/var.get (var alist &optional quiet)
  "Get the symbol VAR from the directory local variables ALIST.

If QUIET is not nil, signals error. Else returns nil on error.
"
  ;; Sanity
  (when (not (symbolp var))
    (if quiet
        nil
      (error "%s: `var' must be a symbol! %S" "jerky//dlv/var.get" var)))
  (alist-get var alist))
;; (jerky//dlv/var.get 'jeff '((jill . "hello there") (jeff . 42)))


(defun jerky//dlv/var.set (var-pair alist)
  "Set the VAR-PAIR entry into the variables ALIST.

VAR-PAIR should be a certain format, which `jerky//dlv/var.create' returns.

Returns the updated alist.
"
  (if (null (alist-get (car var-pair) alist))
      (push var-pair alist)
    (setf (alist-get (car var-pair) alist) (cdr var-pair)))
  alist)
;; (let ((an-alist '((baz qux)))) (jerky//dlv/var.set '(foo bar) an-alist))
;; (let ((an-alist '((foo nil) (baz qux)))) (jerky//dlv/var.set '(foo bar) an-alist))


(defun jerky//dlv/mode.create (mode &rest vars)
  "Create a mode/variables pair for the directory local variables list."
  (cons mode vars))
;; (jerky//dlv.create/mode 'c-mode (jerky//dlv.create/var  "jeff/var" '(:ns-jeff 42 "docstr")))
;; (let ((mode '(c-mode ("jeff/var" :ns-jeff 42 "docstr")))) (cdr mode))


(defun jerky//dlv/mode.get (key alist)
  "Get the KEY list from the directory local variables ALIST.
"
  (alist-get key alist))
;; (let ((alist '((nil . ((indent-tabs-mode . t)
;;                        (fill-column . 80)
;;                        (mode . auto-fill)))
;;                (c-mode . ((c-file-style . "BSD")
;;                           (subdirs . nil)))
;;                ("src/imported"
;;                 . ((nil . ((change-log-default-name
;;                             . "ChangeLog.local"))))))))
;;   (jerky//dlv/mode.get 'c-mode alist))


(defun jerky//dlv/mode.set (mode-list dlv-list)
  "Set the MODE-LIST entry into the DLV-LIST.

MODE-LIST should be a certain format, which `jerky//dlv/mode.create' provides.
"
  (if (null (alist-get (car mode-list) dlv-list))
      (push mode-list dlv-list)
    (setf (alist-get (car mode-list) dlv-list) (cdr mode-list))
    mode-list))
;; (jerky//dlv/mode.set (jerky//dlv.create/mode 'c-mode (jerky//dlv.create/var  "jeff/var" '(:ns-jeff 42 "docstr"))) '((nil . ((a . t) (b . "hello")))))
;; (jerky//dlv/mode.set (jerky//dlv.create/mode 'c-mode (jerky//dlv.create/var  "jeff/var" '(:ns-jeff 42 "docstr"))) '((c-mode . ((a . t) (b . "hello")))))


(defun jerky//dlv/dir.create (dir &rest mode-lists)
  "Create a dir/mode-list pair for the directory local variables list.
"
  (cons dir mode-lists))
;; (jerky//dlv/dir.create "foo/bar" (jerky//dlv.create/mode 'c-mode (jerky//dlv.create/var  "jeff/var" '(:ns-jeff 42 "docstr"))))
;; '("src/imported" . ((nil . ((change-log-default-name . "ChangeLog.local")))))
;;   -> ("src/imported" (nil (change-log-default-name . "ChangeLog.local")))


(defun jerky//dlv/dir.get (dir alist)
  "Get the DIR list of mode/vars from the directory local variables ALIST.
"
  (alist-get dir alist nil nil #'string=))
;; (let ((alist '((nil . ((indent-tabs-mode . t)
;;                        (fill-column . 80)
;;                        (mode . auto-fill)))
;;                (c-mode . ((c-file-style . "BSD")
;;                           (subdirs . nil)))
;;                ("src/imported"
;;                 . ((nil . ((change-log-default-name
;;                             . "ChangeLog.local"))))))))
;;   (jerky//dlv/dir.get "src/imported" alist))


(defun jerky//dlv/dir.set (dir-list dlv-list)
  "Set the DIR-LIST entry into the DLV-LIST.

DIR-LIST should be a certain format, which `jerky//dlv/mode.create'
and `jerky//dlv/dir.create' provide.
"
  (if (null (alist-get dir-list dlv-list))
      (push dir-list dlv-list)
    (setf (alist-get (car dir-list) dlv-list) (cdr dir-list))
    dir-list))


(defun jerky/dlv/set (class directory mode symbol &rest keys-and-options)
  "Create/overwrite a Jerky Directory-Local-Variable (jDLV).

CLASS should be the name of a symbol for creating the
`dir-locals-set-class-variables', It is also used as the jerky key.
If nil, it will be set to:
  (jerky//key/normalize 'dlv namespace symbol)
e.g.:
  (jerky/dlv/set nil \"~/jeff/.config/top-secret\"
                 org-journal-dir ... :namespace :work ...)
    -> CLASS == 'dlv/work/org-journal-dir

DIRECTORY should be the absolute path to the desired directory.

MODE should be the mode the jDLV applies to.

SYMBOL should be the name of an existing symbol, if setting var in Emacs.
If only setting in jDLV, can be nil.

Splits KEYS-AND-OPTIONS into keys, and keyword arg/value pairs.

KEY: A list of key strings/symbols/keywords, or a string key, or
a mix. These must come before any of the keyword args.

Keyword key/value pairs only exist after the KEYS. The keywords are:
  `:value'
  `:docstr'
  `:namespace'
  `:dlv'
  `:quiet'

`:namespace'
  The argument after :namespace will be used as the namespace to set the
  data under. If no namespace is provided, this will only look under
  the default.

`:docstr'
  The argument after :docstr will be evaluated and stored as the
  documentation string.

`:value'
  The argument after :value will be stored as the value.

`:dlv'
  Can also set the (non-jerky) variable to the directory local value if `:dlv' is
  set to `full'/t.
  Options for `:dlv' are:
    - not supplied/nil/`jerky': Only set in jDLV.
    - `emacs':                  Only set in Emacs' Directory Local Variables.
    - `full'/t:                 Set in both jDLV and Emacs' DLV.

`:quiet'
  If non-nil, will suppress error signals.

If not provided, they will be nil.
"
  (message "class: %S, directory: %S, mode: %S, symbol: %S, keys-and-options: %S"
           class directory mode symbol keys-and-options)
  (-let* ((parsed (jerky//parse keys-and-options :dlv :quiet))
          ((&plist :key :namespace :value :docstr :dlv :quiet) parsed)
          (key-dlv (jerky//dlv/dlv.key namespace class symbol quiet))
          mode-dlv)
    (message "key: %S, namespace: %S, value: %S, docstr: %S, dlv: %S, quiet: %S"
             key namespace value docstr dlv quiet)

    (if (not (and (jerky//dlv/verify.dir directory quiet)
                  (or (null namespace)
                      (jerky//dlv/verify.namespace namespace))
                  (jerky//dlv/verify.variable namespace key)))
        ;; Error should be signaled by verify funcs, so we're in quiet mode, so shhh.
        ;; Just return nil.
        nil

      ;;---
      ;; Verfied; proceed.
      ;;---
      ;; If asked to put it in emacs, (try to) do so.
      (when (memq dlv '(t full emacs))
        (if (eq
             :fail-quietly
             (condition-case-unless-debug nil
                 ;; Just catch if this triggers error signal.
                 (symbol-value symbol)
               (error (if quiet
                          :fail-quietly
                        (error "%s: Cannot set directory local variable for variable that doesn't exist. %s"
                               "jerky/dlv" symbol)))))
            ;; Errored on symbol and in quiet mode; skip...
            nil

          ;; Symbol exists; create our dir locals value.
          (setq mode-dlv
                (jerky//dlv/mode.set
                 (jerky//dlv/mode.create mode
                                         (jerky//dlv/var.create
                                          ;; Use actual symbol so it actually sets the right thing!
                                          symbol
                                          ;; ...and use just the value; not the jerky record.
                                          value))
                 nil))
          ;; Set-up a class of dlv variables and apply it to the directory.
          (dir-locals-set-class-variables class mode-dlv)
          (dir-locals-set-directory-class directory class)))

      ;; If asked to put it in jerky, do so.
      (when (memq dlv '(t full nil jerky))
        (jerky/set key-dlv
                   :namespace namespace
                   :value value
                   :docstr docstr
                   :dlv t
                   :directory directory
                   :class class)))))
;; (let ((dir (jerky/get "path/org/journal" :namespace :work)))
;;   (jerky/dlv/set 'org-journal
;;                  dir
;;                  'org-journal-mode
;;                  'org-journal-dir
;;                  "path/org/journal"
;;                  :namespace :work
;;                  :value dir
;;                  :docstr "jDLV for Org-Journal directory"
;;                  :dlv 'full))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(spy/provide :spy 'jerky 'dlv)
(provide 'jerky/dlv)
