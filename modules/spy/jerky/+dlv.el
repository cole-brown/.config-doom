;;; spy/jerky/+dlv.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Jerky Directory Local Variables
;;------------------------------------------------------------------------------

(require 's)
(require 'dash)
(imp:require :jerky 'debug)
(require 'mis0)


;;------------------------------------------------------------------------------
;; Constants
;;------------------------------------------------------------------------------

(defconst jerky/dlv/safing.skip
  '(:already already :is-safe is-safe :skip skip :safed safed)
  "Approved values for saying that, \"this DLV is already marked as 'safe for
directory local use'.\"")


;;------------------------------------------------------------------------------
;; Variables
;;------------------------------------------------------------------------------

;;------------------------------
;; Path -> DLV "class"
;;------------------------------

(defvar jerky//dlv/path->class nil
  "Alist of path to: '(directory-class-symbol current-dlv-values)")
;; (makunbound 'jerky//dlv/path->class)


;;------------------------------
;; Auto-Namespacing
;;------------------------------

(defvar jerky//dlv/namespace.local nil
  "Directory Local Variable for holding the directory's namespace.")


(defvar jerky//dlv/uid.next 0
  "Some random int for creating unique DLV class symbol names.")

;; (defconst jerky//dlv/var.prefix "jerky//dlv//"
;;   "Jerky's dir-local variables made via `jerky/dlv.set' use this as their prefix.")


;; (defconst jerky//dlv/var.format (format "%s%%s" jerky//dlv/var.prefix)
;;   "Jerky's dir-local variables made via `jerky/dlv.set' use this format.")


;;------------------------------------------------------------------------------
;; Path -> DLV "class"
;;------------------------------------------------------------------------------

(defun jerky//dlv.class.get (dir)
  "Get the DLV class symbol and current value list in a cons.

Returns (nil . nil) if not found."
  (alist-get dir jerky//dlv/path->class nil nil #'string=))


(defun jerky//dlv.class.set (dir class value)
  "Set DLV dir/class to value in Emacs, and save to our `jerky//dlv/path->class'."
  (setf (alist-get dir jerky//dlv/path->class nil nil #'string=)
        (list (cons class value)))
  (jerky//debug "jerky//dlv.class.set" "Set `jerky//dlv/path->class' to: %S"
                jerky//dlv/path->class))
;; (jerky//dlv.class.set "/foo/bar" 'foo-dlv '(nil . ((value-0 . t) (value-1 . "tee"))))
;; jerky//dlv/path->class
;; (jerky//dlv.class.get "/foo/bar")
;; (jerky//dlv.class.set "/foo/bar" 'foo-dlv '(nil . ((value-0 . nil) (value-1 . "tee"))))
;; jerky//dlv/path->class
;; (jerky//dlv.class.get "/foo/bar")
;; (jerky//dlv.class.set "/test/path" 'test-dlv '(nil . ((value-0 . "hello") (value-1 . "there"))))
;; jerky//dlv/path->class
;; (jerky//dlv.class.get "/foo/bar")
;; (jerky//dlv.class.get "/test/path")


;;------------------------------------------------------------------------------
;; Verification
;;------------------------------------------------------------------------------

(defun jerky//dlv/verify.dir (dir &optional quiet)
  "Verify DIR is valid for `jerky/dlv.set/<...>'.

If QUIET is not nil, signals error. Else returns nil on error.
Returns directory name on success.
"
  (cond ((null dir)
         (if quiet
             nil
           (error "%s: Cannot verify `nil' directory: %S"
                  "jerky//dlv/verify.dir" dir)))

        ((not (file-name-absolute-p dir))
         (if quiet
             nil
           (error "%s: Directory path must be absolute. %s"
                  "jerky//dlv/verify.dir" dir)))

        ((not (directory-name-p dir))
         ;; Is absolute; needs fixed to have final slash.
         (file-name-as-directory dir))
        ;; Old way: error on not directory-name-p.
        ;; (if quiet
        ;;      nil
        ;;    (error "%s: Path must be a directory path (add '/'?). %s"
        ;;           "jerky//dlv/verify.dir" dir)))
        ;; ((not (file-exists-p dir))
        ;;  (if quiet
        ;;      nil
        ;;    (error "%s: Directory must exist. %s"
        ;;           "jerky//dlv/verify.dir" dir)))

        ;; Ok as-is.
        (t
         dir)))
;; Bad:
;; (jerky//dlv/verify.dir "relative/path/file")
;; (jerky//dlv/verify.dir "c:/absolute/path/file")
;; (jerky//dlv/verify.dir "relative/path/")
;; (jerky//dlv/verify.dir "c:/absolute/path/")
;; Good:
;; (jerky//dlv/verify.dir user-emacs-directory)
;; (jerky//dlv/verify.dir "~/")


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


;;------------------------------------------------------------------------------
;; DLV Setter/Getter Helpers
;;------------------------------------------------------------------------------

(defun jerky//dlv/uid.get ()
  "Get a Unique ID. Increment the UID counter for the next guy."
  (let ((uid jerky//dlv/uid.next))
    (setq jerky//dlv/uid.next (1+ jerky//dlv/uid.next))
    uid))
;; jerky//dlv/uid.next
;; (jerky//dlv/uid.get)


(defun jerky/dlv/key.uid (namespace class &optional symbol)
  "Create a unique jerky key symbol from inputs each time it is called.

CLASS should be the name of a symbol for creating the
`dir-locals-set-class-variables' or nil.

If CLASS is non-nil, this returns a symbol-name from string:
  (jerky//key/normalize 'dlv uid [NAMESPACE] CLASS)
Else, this returns a symbol-name from string:
  (jerky//key/normalize 'dlv uid [NAMESPACE] SYMBOL)
where `uid' is a unique integer.

If QUIET is non-nil, return nil instead of raise error signal.
"
  (make-symbol
   (jerky//key/normalize
    ;; This is a silly way to build this, probably? But it works.
    (cons :dlv
          (cons (number-to-string (jerky//dlv/uid.get))
                (if namespace
                    (cons namespace
                          (if class
                              (list class)
                            (list symbol)))
                  ;; No namespace - class or symbol?
                  (if class
                      (list class)
                    (list symbol))))))))
;; (jerky//dlv/key.uid :work nil 'org-journal)
;; (jerky//dlv/key.uid :work 'class-name 'org-journal-dir)
;; (jerky//dlv/key.uid nil nil 'org-journal-dir)


(defun jerky/dlv/key.static (namespace class &optional symbol)
  "Create a jerky key symbol from inputs. Return value will be the same for
the same inputs.

CLASS should be the name of a symbol for creating the
`dir-locals-set-class-variables' or nil.

If CLASS is non-nil, this returns:
  (jerky//key/normalize 'dlv [NAMESPACE] CLASS)
Else, this returns:
  (jerky//key/normalize 'dlv [NAMESPACE] SYMBOL)

If QUIET is non-nil, return nil instead of raise error signal.
"
  (make-symbol
   (jerky//key/normalize
    ;; This is a silly way to build this, probably? But it works.
    (cons :dlv
          (if namespace
              (cons namespace
                    (if class
                        (list class)
                      (list symbol)))
            ;; No namespace - class or symbol?
            (if class
                (list class)
              (list symbol)))))))
;; (jerky/dlv/key.static :work 'org-class 'org-journal)
;; (jerky/dlv/key.static :work nil 'org-journal)
;; (jerky/dlv/key.static :work nil 'org-journal-dir)
;; (jerky/dlv/key.static nil nil 'org-journal-dir)


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
    (cons var
          value)))
;; Error:
;; (jerky//dlv/var.create 'jeff/var '(:ns-jeff 42 "docstr"))
;; Ok:
;; (jerky//dlv/var.create 'jeff/var '(:ns-jeff 42 "docstr"))
;; (let ((var '(jeff/var :ns-jeff 42 "docstr"))) (cdr var))


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
;; (jerky//dlv/var.get 'jeff/var '((jill . "hello there") (jeff/var :ns-jeff 42 "docstr") (jeff . 42)))


(defun jerky//dlv/var.set (var-pair alist)
  "Set the VAR-PAIR entry into the variables ALIST.

VAR-PAIR should be a certain format, which `jerky//dlv/var.create' returns.

Returns the updated alist.
"
  (if (null (assoc (car var-pair) alist))
      (push var-pair alist)
    (setf (alist-get (car var-pair) alist) (cdr var-pair)))
  alist)
;; (let ((an-alist '((baz . qux)))) (jerky//dlv/var.set '(foo bar) an-alist))
;; (let ((an-alist '((foo) (baz . qux)))) (jerky//dlv/var.set '(foo . bar) an-alist))


(defun jerky//dlv/mode.create (mode value &optional quiet)
  "Create a mode/variables pair for the directory local variables list.

If QUIET is not nil, signals error. Else returns nil on error.
"
  ;; Sanity
  (if (not (symbolp mode))
      (if quiet
          nil
        (error "%s: `mode' must be a symbol! %S" "jerky//dlv/mode.create" mode))
    (list mode
          value)))
;; (jerky//dlv/mode.create 'c-mode (jerky//dlv/var.create 'jeff/var '(:ns-jeff 42 "docstr")))
;; (let ((mode '(c-mode (jeff/var :ns-jeff 42 "docstr")))) (cdr mode))


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
(jerky//dlv/mode.get 'c-mode (jerky//dlv/mode.create 'c-mode (jerky//dlv/var.create 'jeff/var '(:ns-jeff 42 "docstr"))))


(defun jerky//dlv/mode.set (mode-list dlv-list)
  "Set the MODE-LIST entry into the DLV-LIST.

MODE-LIST should be a certain format, which `jerky//dlv/mode.create' provides.
"
  (if (null (alist-get (car mode-list) dlv-list))
      (push mode-list dlv-list)
    (setf (alist-get (car mode-list) dlv-list) (cdr mode-list))
    mode-list))
;; (jerky//dlv/mode.set (jerky//dlv/mode.create 'c-mode (jerky//dlv/var.create 'jeff/var '(:ns-jeff 42 "docstr"))) '((nil . ((a . t) (b . "hello")))))
;; (jerky//dlv/mode.set (jerky//dlv/mode.create 'c-mode (jerky//dlv/var.create 'jeff/var '(:ns-jeff 42 "docstr"))) '((c-mode . ((a . t) (b . "hello")))))


(defun jerky//dlv/dir.create (dir &rest mode-lists)
  "Create a dir/mode-list pair for the directory local variables list.
"
  (cons dir mode-lists))
;; (jerky//dlv/dir.create "foo/bar" (jerky//dlv/mode.create 'c-mode (jerky//dlv/var.create  'jeff/var '(:ns-jeff 42 "docstr"))))
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


(defun jerky//dlv/dir.set (dir-alist dlv-alist)
  "Set the DIR-ALIST entry into the DLV-ALIST.

DIR-ALIST should be a certain format, which `jerky//dlv/mode.create'
and `jerky//dlv/dir.create' provide.
"
  (if (null (alist-get dir-alist dlv-alist))
      (push dir-alist dlv-alist)
    (setf (alist-get (car dir-alist) dlv-alist) (cdr dir-alist))
    dir-alist))
;; (jerky//dlv/dir.set (jerky//dlv/dir.create "foo/bar" (jerky//dlv/mode.create 'c-mode (jerky//dlv/var.create  'jeff/var '(:ns-jeff 42 "docstr")))) nil)


;;------------------------------------------------------------------------------
;; Mark as Safe for DLV
;;------------------------------------------------------------------------------

(defun jerky//dlv/mark-as-safe (symbol validation-predicate)
  "Mark SYMBOL as a safe directory local variable as long as the DLV value
passes the VALIDATION-PREDICATE."
  ;; Add the VALIDATION-PREDICATE function to the SYMBOL's `safe-local-variable' property.
  (put symbol 'safe-local-variable validation-predicate))
;; (get 'taskspace//dlv/group 'safe-local-variable)
;; (get 'jerky//dlv/namespace.local 'safe-local-variable)


;;------------------------------------------------------------------------------
;; DLV API
;;------------------------------------------------------------------------------

(defun jerky/dlv/set (class directory mode symbol &rest keys-and-options)
  "Create/overwrite a Jerky Directory-Local-Variable (jDLV).

CLASS should be the name of a symbol for creating the
`dir-locals-set-class-variables'. It is also used as the jerky key.
You can use `jerky/dlv/key.static' or `jerky/dlv/key.uid' to create a DLV key:
  (jerky/dlv/key.uid namespace class symbol)
  (jerky/dlv/key.static namespace class symbol)

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
  `:safe'
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

`:safe'
  - If `functionp', store that predicate in the symbol's `safe-local-variable'
    slot for Emacs to use.
    + NOTE: `:dlv' must be a setting that allows for setting the variable/value
      into Emacs' DLVs.
  - If a keyword/symbol in `jerky/dlv/safing.skip', do nothing;
    SYMBOL is assumed to be already marked safe for Directory Local Value use.
  - If non-nil, I want to store the value provided in
    `safe-local-variable-values', but have not got that to actually work.
    + So currently, will error unless `:quiet'.
    + NOTE: `:dlv' must be a setting that allows for setting the variable/value
      into Emacs' DLVs.
  - If nil - will error unless `:quiet'.

`:quiet'
  If non-nil, will suppress error signals.

If not provided, they will be nil.
"
  (-let* (((key-jerky kwargs) (jerky//parse keys-and-options t :dlv :safe :quiet))
          ((&plist :namespace :value :docstr :dlv :safe :quiet) kwargs)
          dlv.class
          (dbg.func "jerky/dlv/set"))

    (when (not (null key-jerky))
      (error "jerky/dlv/set: unexpected args before keywords: %S" key-jerky))

    (let ((dir (jerky//dlv/verify.dir directory quiet)))
      (if (not (and dir
                    (or (null namespace)
                        (jerky//dlv/verify.namespace namespace))
                    ;; (jerky//dlv/verify.variable namespace key-jerky)
                    ))
          ;; Error should be signaled by verify funcs, so we're in quiet mode, so shhh.
          ;; Just return nil.
          nil

        ;;---
        ;; Verfied; proceed.
        ;;---
        ;; If asked to put it in emacs, (try to) do so.
        (jerky//debug dbg.func "dlv type: %S -emacs-> %S" dlv (memq dlv '(full emacs t)))
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
            (if jerky//debugging
                (let* ((var.create (jerky//dlv/var.create
                                    ;; Use actual symbol so it actually sets the right thing!
                                    symbol
                                    ;; ...and use just the value; not the jerky record.
                                    value))
                       (mode.create (jerky//dlv/mode.create mode var.create))
                       (mode.set (jerky//dlv/mode.set mode.create nil)))
                  (jerky//debug dbg.func "var.create: %S" var.create)
                  (jerky//debug dbg.func "mode.create: %S" mode.create)
                  (jerky//debug dbg.func "mode.set: %S" mode.set)))

            (setq dlv.class
                  (jerky//dlv/mode.set
                   (jerky//dlv/mode.create mode
                                           (jerky//dlv/var.create
                                            ;; Use actual symbol so it actually sets the right thing!
                                            symbol
                                            ;; ...and use just the value; not the jerky record.
                                            value))
                   nil))

            (jerky//debug dbg.func "DLV created `%S': %s" class dlv.class)

            ;; Update from saved dlv settings?
            (if-let ((alist/dlv.dir (jerky//dlv.class.get directory)))
                (let* ((alist/dlv.class (alist-get class alist/dlv.dir))
                       (alist/dlv.mode (alist-get mode alist/dlv.class)))
                  (jerky//debug dbg.func "Existing dlv for '%S': %S"
                                directory
                                alist/dlv.dir)
                  (jerky//debug dbg.func "Existing dlv.class for '%S': %S"
                                class
                                alist/dlv.class)
                  (jerky//debug dbg.func "Existing dlv.mode for '%S': %S"
                                mode
                                alist/dlv.mode)
                  (jerky//debug dbg.func "  Mode already exists? %S"
                                (not (null alist/dlv.mode)))

                  ;; Update/set DLV settings for this mode.
                  (when alist/dlv.mode
                    ;; Update w/ new dlv settings.
                    (dolist (element.class dlv.class)
                      ;; Look for correct mode in saved settings...
                      (when (eq (car element.class) mode)
                        ;; Get mode's variable key/value pairs list.
                        (let ((element.mode (cdr element.class)))
                          ;; Update alist with new values.
                          (jerky//debug dbg.func "Add vars: %S" element.mode)
                          (dolist (kvp element.mode)
                            (setf (alist-get (car kvp) alist/dlv.mode) (cdr kvp))
                            (jerky//debug dbg.func "  Updated key/value in alist/dlv.mode: %S -> %S"
                                          kvp alist/dlv.mode)))))

                    ;; Update/set DLV class settings w/ updated mode settings.
                    (setf (alist-get mode alist/dlv.class) alist/dlv.mode)
                    (jerky//debug dbg.func "Updated mode `%S' in alist/dlv.class: %S -> %S"
                                  mode alist/dlv.mode alist/dlv.class))

                  ;; Update what we'll be setting in Emacs.
                  (setq dlv.class alist/dlv.class)

                  ;; Update our saved DLV alist.
                  (jerky//dlv.class.set directory class dlv.class)

                  (jerky//debug dbg.func "Updated jerky//dlv.class for dir '%s': class: %S, mode: %S\n  -> jerky alist: %S"
                                directory class dlv.class
                                jerky//dlv/path->class))

              ;; Don't have this dir yet. Save it.
              (jerky//dlv.class.set directory class dlv.class)
              (jerky//debug dbg.func "Set jerky//dlv.class for dir '%s': class: %S, mode: %S\n  -> jerky alist: %S"
                            directory class dlv.class
                            jerky//dlv/path->class))

            ;; Set-up a class of dlv variables and apply it to the directory.
            (jerky//debug dbg.func "DLV class var `%S': %s" class dlv.class)
            (dir-locals-set-class-variables class dlv.class)
            (jerky//debug dbg.func "DLV class dir `%S': %s" class dir)
            (dir-locals-set-directory-class dir class)
            (jerky//debug dbg.func "Emacs DLV Class: %S"
                          (dir-locals-get-class-variables class))

            ;; Should we marke it as safe?
            ;; ...If we don't, it's DLV value won't ever be used.
            (cond ((functionp safe)
                   ;; Mark as safe if provided predicate says so.
                   (jerky//dlv/mark-as-safe symbol safe))

                  ;; User is saying they know what they're doing.
                  ((memq safe jerky/dlv/safing.skip)
                   nil)

                  ;; Or mark just this value as safe?
                  ((not (null safe))
                   ;; NOTE: This doesn't seem to work? :|
                   ;; (push (cons symbol value) safe-local-variable-values)
                   (unless quiet
                     (error (concat "jerky/dlv/set: "
                                    "I still haven't gotten `safe-local-variable-values' to work... "
                                    "Use a predicate function.")))
                   nil)

                  ;; Not instructed in how to safe - error at them.
                  (t
                   (unless quiet
                     (error (concat "jerky/dlv/set: "
                                    "You've not marked this as a safe DLV... "
                                    "Use a predicate function or say it already is safed.")))
                   nil))))

        ;; If asked to put it in jerky, do so.
        (jerky//debug dbg.func "dlv type: %S -jDLV-> %S" dlv (memq dlv '(full jerky t nil)))
        (when (memq dlv '(jerky full t nil))
          (jerky/set 'jerky 'dlv class
                     :namespace namespace
                     :value value
                     :docstr docstr
                     :dlv t
                     :directory directory
                     :class class))))))
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


(defun jerky/dlv/namespace.set (directory namespace)
  "Sets Jerky's local NAMESPACE for the DIRECTORY."
  (jerky//debug "jerky//dlv/namespace.set" "\n  dir: %s \n  ns:  %S"
                directory namespace)

  (if (not (jerky/namespace/has namespace))
      (error "jerky/dlv/namespace.set: No known namespace called '%s'" namespace)

    (jerky//debug "jerky//dlv/namespace.set" "  -> `jerky//dlv/namespace.local'")
    (jerky/dlv/set 'jerky//dlv.class/namespace
                   directory
                   nil ; all modes
                   'jerky//dlv/namespace.local
                   ;; :namespace namespace
                   :value namespace
                   :docstr (format "Jerky's default namespace for directory '%s'"
                                   directory)
                   :dlv 'full
                   :safe #'jerky//namespace/valid)

    (mis0/init/message (concat "jerky/dlv/namespace.set: \n"
                               "  directory:  %S\n"
                               "  namespace:  %S\n"
                               "  dlv-pred:   %S")
                       directory
                       namespace
                       (get 'jerky//dlv/namespace.local 'safe-local-variable))))
;; (jerky/get 'path 'org 'journal :namespace :work)
;;   -> "d:/home/spydez/.lily.d/logbook/work/"
;; (jerky/dlv/namespace.set "d:/home/work/.lily.d/logbook/work/" :work)
;; (jerky/dlv/namespace.set "d:/home/work/.lily.d/taskspace/work/" :work)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :jerky 'dlv)
