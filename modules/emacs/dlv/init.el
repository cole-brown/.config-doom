;;; emacs/dlv/init.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Directory Local Variables
;;------------------------------------------------------------------------------

(require 's)
(require 'dash)


;;------------------------------------------------------------------------------
;; Constants
;;------------------------------------------------------------------------------

(defconst dlv/key.separator "/"
  "Used to create keys in `dlv/key.create'.")


(defconst dlv//const/safe.valid '(:safe t)
  "Valid constant values for `safe' in `dlv/set'.")


;; ;;------------------------------------------------------------------------------
;; ;; Variables
;; ;;------------------------------------------------------------------------------
;;
;; ;;------------------------------
;; ;; Path -> DLV "class"
;; ;;------------------------------
;;
;; (defvar dlv//path->class nil
;;   "Alist of path to: '(directory-class-symbol current-dlv-values)")
;; ;; (makunbound 'dlv//path->class)


;;------------------------------------------------------------------------------
;; Debugging Help
;;------------------------------------------------------------------------------

(defvar dlv//debugging nil
  "Debug flag.")


(defun dlv//debug/toggle ()
  "Toggle debugging for DLV."
  (interactive)
  (setq dlv//debugging (not dlv//debugging))
  (message "dlv//debugging: %s"
           (if dlv//debugging
               "enabled"
             "disabled")))


(defun dlv//debug (func msg &rest args)
  "Print out a debug message if debugging."
  (when dlv//debugging
    (apply #'message
           (concat func ": " msg)
           args)))
;; (dlv//debug "test")


;;------------------------------------------------------------------------------
;; DLV Setter/Getter Helpers
;;------------------------------------------------------------------------------

(defun dlv//key.normalize (args)
  "Turn args into a key string.

(dlv//key.normalize '(\"a/b\" \"c\"))
  -> a/b/c
(dlv//key.normalize '(\"a/b\" c))
  -> a/b/c
(dlv//key.normalize '(\"a\" b c))
  -> a/b/c
"
  (let ((normalize (lambda (arg)
                     (cond ((null arg)
                            nil)

                           ((stringp arg)
                            arg)

                           ((symbolp arg)
                            (symbol-name arg))

                           ((functionp arg)
                            (funcall arg))

                           ;; Fail - don't want to be crazy and blindly convert something.
                           (t
                            (error (concat "%s: Can't convert '%S' to string for conversion "
                                           "of keys into key list.")
                                   "dlv//key.normalize"
                                   arg))))))
    (string-join
     (if (listp args)
         ;; Normalize a list:
         (-filter (lambda (x) (not (null x))) ;; Ignore nils from conversion.
                  ;; Convert a list of whatever into a list of strings.
                  (-map normalize args))
       ;; Normalize a thing into a list of string:
       (list (funcall normalize args)))
     dlv/key.separator)))
;; (dlv//key.normalize "hi")
;; (dlv//key.normalize 'hi)
;; (dlv//key.normalize '(h i))


(defun dlv/key.create (class &rest optional)
  "Create a key symbol from inputs. Return value will be the same for
the same inputs.

CLASS should be the name of a symbol for creating the
`dir-locals-set-class-variables' or nil."
  (make-symbol
   (jerky//key/normalize (cons class optional))))
;; (dlv/key.create 'org-class 'org-journal)
;; (dlv/key.create 'org-journal)
;; (dlv/key.create 'org-journal-dir)
;; (dlv/key.create 'org-journal-dir)


;;------------------------------------------------------------------------------
;; Validation
;;------------------------------------------------------------------------------

(defun dlv//validate/class.symbol (caller class &optional signal-error)
  "Check that CLASS is valid for CALLER (probably `dlv/set')."
  (cond ((symbolp class)
         t)

        ((not (null signal-error))
         (error "%s: Invalid CLASS value; must be a symbol: %S. Got: %S"
                caller
                dlv//const/safe.valid
                safe))

        ;; Invalid, but no signaling - return nil.
        (t
         nil)))

(defun dlv//validate/safe (caller safe &optional signal-error)
  "Check that SAFE param is valid for CALLER (probably `dlv/set')."
  (cond ((or (functionp safe)
             (memq safe dlv//const/safe.valid))
         t)

        ((not (null signal-error))
         (error "%s: Invalid SAFE value; must be a function or one of: %S. Got: %S"
                caller
                dlv//const/safe.valid
                safe))

        ;; Invalid, but no signaling - return nil.
        (t
         nil)))


(defun dlv//validate/var.symbol (caller symbol &optional signal-error)
  "Check that SYMBOL is valid for a DLV variable.

If SIGNAL-ERROR is non-nil, will signal an error if symbol is invalid."
  ;; The symbol must be... a symbol.
  (cond ((symbolp symbol)
         ;; Valid symbol.
         t)

        ((not (null signal-error))
         (error "%s: Invalid DLV varible symbol. `symbol' must be a symbol! %S"
                caller
                symbol))

        ;; Invalid, but no signaling - return nil.
        (t
         nil)))


(defun dlv//validate/var.value (caller value &optional signal-error)
  "Currently: just returns true.

If any checks can be done in the future, will check that provided value is
valid for a DLV variable."
  ;; I'm not sure what /isn't/ valid, so currently this function is just to make the code look cleaner.
  (cond (t
         ;; Valid value.
         t)

        ((not (null signal-error))
         (error "%s: Invalid DLV variable value. `value' must be _INSERT SOMETHING HERE_! %S"
                caller
                value))

        ;; Invalid, but no signaling - return nil.
        (t
         nil)))

(defun dlv//validate/var.pair (caller pair &optional signal-error)
  "Check that PAIR is a valid 2-tuple of a symbol and something for DLVs."
  ;; Must be a 2-tuple, so cons is good.
  ;; If it's a list of the correct length, convert to a cons.
  (cond ((and (consp pair)
              (dlv//validate/var.symbol caller (car pair) signal-error)
              (dlv//validate/var.value  caller (cdr pair) signal-error))
         pair)

        ((and (listp pair)
              (= (length pair) 2)
              (dlv//validate/var.symbol caller (nth 0 pair) signal-error)
              (dlv//validate/var.value  caller (nth 1 pair) signal-error))
         ;; Convert to cons.
         (cons (nth 0 pair)
               (nth 1 pair)))

        ;; Nope.
        (t
         (if (not (null signal-error))
             (error "%s: Failed validation: Pair must be a valid 2-tuple of a symbol and a value. Got: %S"
                    caller pair)
           nil))))


(defun dlv//validate/dlv.vars (caller dlv.vars &optional signal-error)
  "Check that DLV.VARS and each element in it are valid."
  (let ((valid t))
    (if (or (not dlv.vars)
            (not (listp dlv.vars)))
        (if (not (null signal-error))
            (error "%s: `dlv.vars' failed validation! Must be a list with symbol/value tuples. %S"
                   caller dlv.vars)
          ;; Don't error - just fail value of nil.
          (setq valid nil)
          valid)
      ;; Walk the list and return `valid' when done checking.
      (dolist (pair dlv.vars valid)
        (if (not (dlv//validate/var.pair caller pair signal-error))
            (if (not (null signal-error))
                ;; Should have already errored, but just in case:
                (error "%s: `pair' failed validation! %S"
                       caller pair)
              ;; Don't error - just set our success/failure value.
              (setq valid nil)))))
    ;; Return our validation summary.
    valid))


(defun dlv//validate/mode.symbol (caller mode &optional signal-error)
  "Checks that MODE is valid for a DLV mode. Must be a symbol or nil."
  ;; Valid?
  (cond ((or (null mode)
             (symbolp mode))
         t)

        ;; Invalid - error or return nil.
        ((not (null signal-error))
         (error "%s: `mode' must be a symbol! %S"
                caller
                mode))
        (t
         nil)))


(defun dlv//validate/mode.entry (caller mode.entry &optional signal-error)
  "Checks that MODE.ENTRY is valid for a DLV mode.

Must be a cons with a valid mode and valid vars."
  (cond ((and (consp mode.entry)
              (dlv//validate/mode.symbol caller (car mode.entry) signal-error)
              (dlv//validate/dlv.vars caller (cdr mode.entry) signal-error))
         t)

        ;; Invalid - error or return nil.
        ((not (null signal-error))
         ;; Probably wasn't a cons, since the rest should've errored in their funcs.
         (error "%s: `mode.entry' is not valid! Must be a cons with valid members. %S"
                caller
                mode))

        (t
         nil)))


(defun dlv//validate/dir.path (caller path &optional signal-error)
  "Checks that PATH is valid for a DLV directory.

Must be a cons with a valid mode and valid vars."
  (cond ((null path)
         (if (not (null signal-error))
             (error "%s: `nil' is an invalid directory: %S"
                    caller path)
             nil))

        ((not (file-name-absolute-p path))
         (if (not (null signal-error))
             (error "%s: Directory path must be absolute. %s"
                    caller path)
           nil))

        ((not (directory-name-p path))
         ;; Is absolute; needs fixed to have final slash.
         (file-name-as-directory path))

        ;; Ok as-is.
        (t
         path)))
;; Bad:
;; (dlv//validate/dir.path "test" "relative/path/file" :error)
;; (dlv//validate/dir.path "test" "relative/path/" :error)
;; Ok, updated:
;; (dlv//validate/dir.path "test" "c:/absolute/path/no-slash" :error)
;; Good:
;; (dlv//validate/dir.path "test" user-emacs-directory :error)
;; (dlv//validate/dir.path "test" "~/" :error)
;; (dlv//validate/dir.path "test" "c:/absolute/path/slash/" :error)


(defun dlv//validate/dir.entry (caller dir.entry &optional signal-error)
  "Checks that DIR.ENTRY is valid for a DLV mode.

Must be a cons with a valid path and valid mode entries."
  (let ((valid t))
    (cond ((and (consp dir.entry)
                (dlv//validate/dir.path caller (car dir.entry) signal-error))
           ;; Path is valid. Check all the entries.
           (dolist (mode.entry (cdr dir.entry))
             (unless (dlv//validate/mode.entry caller mode.entry signal-error)
               (if (not (null signal-error))
                   ;; Probably wasn't a cons, since the rest should've errored in their funcs.
                   (error "%s: `dir.entry' is not valid! Must be a cons with valid members. %S"
                          caller
                          mode)
                 (setq valid nil))))
           ;; Return our summary.
           valid)

          ;; Invalid - error or return nil.
          ((not (null signal-error))
           ;; Probably wasn't a cons, since the rest should've errored in their funcs.
           (error "%s: `dir.entry' is not valid! Must be a cons with valid members. %S"
                  caller
                  mode))

          (t
           nil))))


(defun dlv//validate/dlv (caller dlv &optional signal-error)
  "Checks that DLV is a valid DLV structure (dirs and/or modes)."
  (let ((valid t))
    (if (not (listp dlv))
        (if (not (null signal-error))
            ;; Probably wasn't a cons, since the rest should've errored in their funcs.
            (error "%s: `dir.entry' is not valid! Must be a cons with valid members. %S"
                   caller
                   mode)
          (setq valid nil))

      ;; Have a list - figure out if all the things in it are valid.
      (setq valid
            (-all? (lambda (dir-or-mode.entry)
                     (or (dlv//validate/dir.entry caller dir-or-mode.entry signal-error)
                         (dlv//validate/mode.entry caller dir-or-mode.entry signal-error)))
                   dlv)))
    ;; Return the summary.
    valid))


;;------------------------------------------------------------------------------
;; Mark as Safe for DLV
;;------------------------------------------------------------------------------

(defun dlv//vars/safe (caller symbol validation-predicate)
  "Mark SYMBOL as a safe directory local variable as long as the
(directory-local) value passes the VALIDATION-PREDICATE.

If VALIDATION-PREDICATE is a member of `dlv//const/safe.valid', does nothing.

If VALIDATION-PREDICATE is something else, raises an error signal."
  (let ((func.name "dlv//vars/safe"))
    (if (dlv//validate/safe caller validation-predicate :error)
        ;; If it /is/ a member of `dlv//const/safe.valid', we don't need to do anything.
        (if (memq validation-predicate dlv//const/safe.valid)
            (progn
              ;; If it /is/ a member of `dlv//const/safe.valid', we don't need to do anything.
              (dlv//debug func.name "symbol %S already safe: %S"
                          symbol
                          validation-predicate)
              ;; Just rerturn something?
              validation-predicate)

          (dlv//debug func.name "Setting symbol %S `safe-local-variable' slot to: %S"
                      symbol
                      validation-predicate)
          ;; Add the VALIDATION-PREDICATE function to the SYMBOL's `safe-local-variable' property.
          (prog1
              (put symbol 'safe-local-variable validation-predicate)

            (dlv//debug func.name "Symbol %S `safe-local-variable' slot is now: %S"
                        symbol
                        (get symbol 'safe-local-variable))))

      ;; Else not a valid VALIDATION-PREDICATE or 'already safe' const.
      ;; Probably already error, but to be safe:
      (error "%s: Cannot mark symbol %S as safe. VALIDATION-PREDICATE was not valid: %S"
             caller
             symbol
             validation-predicate))))
;; (put 'test/local 'safe-local-variable nil)
;; (makunbound 'test/local)
;; (setq test/local t)
;; (get 'test/local 'safe-local-variable)
;; (dlv//vars/safe "test-00" 'test/local 'boundp)
;; (get 'test/local 'safe-local-variable)
;;
;; (put 'test/local 'safe-local-variable nil)
;; (makunbound 'test/local)
;; (setq test/local t)
;; (dlv//vars/safe "test-01" 'test/local :safe)
;; (get 'test/local 'safe-local-variable)


;;------------------------------------------------------------------------------
;; DLV structures
;;------------------------------------------------------------------------------

;; TODO: comment out any that end up being unused until such a time as they're used or at least tested.

;;------------------------------
;; Variables
;;------------------------------

(defun dlv//vars/pair.create (symbol value safe)
  "Create the key/value pair from SYMBOL and VALUE for a variable for the
directory local variables list.

Mark symbol as safe-for-DLV via predicate function if SAFE is a function.
Do nothing if SAFE is a member of `dlv//const/safe.valid'.
Error otherwise."
  (let ((func.name "dlv//vars/pair.create"))
    (if (not (and (dlv//validate/var.symbol func.name symbol :error)
                  (dlv//validate/var.value func.name value :error)
                  (dlv//validate/safe func.name safe :error)))
        (error "%s: Failed to validate SYMBOL, VALUE, and/or SAFE! %S %S %S"
               func.name
               symbol value safe)
      ;; Mark SYMBOL with SAFE, then create/return the var pair.
      (dlv//vars/safe func.name symbol safe)
      (cons symbol
            value))))
;; (dlv//vars/pair.create 'jeff/var '(:ns-jeff 42 "docstr") :safe)


(defun dlv//vars/pair.get (symbol dlv.vars)
  "Get the symbol SYMBOL from the directory local variables DLV.VARS.

If QUIET is not nil, signals error. Else returns nil on error."
  (let ((func.name "dlv//vars/pair.get"))
    (unless (dlv//validate/var.symbol func.name symbol :error)
      (error "%s: `symbol' failed validation! %S"
             "dlv//pair.get" symbol))
    (alist-get symbol dlv.vars)))
;; (dlv//vars/pair.get 'jeff '((jill . "hello there") (jeff . 42)))


(defun dlv//vars/pair.set (pair dlv.vars)
  "Updates or adds the PAIR entry into the variables DLV.VARS.

PAIR should be a certain format, which `dlv//pair.create' returns.

Returns the updated alist."
  (let ((func.name "dlv//vars/pair.set"))
    (if (not (dlv//validate/var.pair func.name pair :error))
        ;; Should have already errored, but just in case:
        (error "%s: `pair' failed validation! %S"
               func.name pair)

      ;; Valid - set/update the var in the alist.
      (if (null (assoc (car pair) dlv.vars))
          (push pair dlv.vars)
        (setf (alist-get (car pair) dlv.vars) (cdr pair)))
      dlv.vars)))
;; (let ((an-alist '((baz . qux)))) (dlv//pair.set '(foo bar) an-alist))


(defun dlv//vars/create (&rest tuples)
  "Create the key/value tuples for supplying to e.g. `dlv//mode/entry.create'.

TUPLES must be an alist of 3-tuples of: (symbol value safe).
  - SYMBOL must be a symbol.
  - VALUE can be anything.
  - SAFE must be a function or one of: (t :safe)
    + If a function, will set symbol's `safe-local-variable' slot to that function. "
  (let ((func.name "dlv//vars/create"))
    (if tuples
        (let (dlv.vars)
          ;; Validate alist tuples and push valids to the output list.
          (dolist (tuple tuples)
            (if (or (not (listp tuple))
                    (not (= 3 (length tuple))))
                (error (concat "%s: `tuple' failed validation! "
                               "Must be a list of length 3: (symbol value safe). "
                               "Got: %S - list? %S length? %S")
                       func.name tuple
                       (listp tuple)
                       (length tuple))

            ;; Validate and create pair.
            (push (dlv//vars/pair.create (nth 0 tuple)
                                         (nth 1 tuple)
                                         (if (> (length tuple) 2)
                                             (nth 2 tuple)
                                           ;; Assume 2-tuples are implicitly 'already safe'?
                                           :safe))
                  dlv.vars)))
          ;; Success - return the created alist.
          dlv.vars)

      ;; No alist at all? Don't know what to do with that other than error.
      (error "%s: `tuples' must be an alist of (symbol value safe) 3-tuples! %S"
             func.name tuples))))
;; (dlv//vars/create '(one "one" :safe) '(two "two" boundp))


;;------------------------------
;; Modes
;;------------------------------

(defun dlv//mode/vars.get (mode dlv-alist)
  "Get the MODE's alist of variables from the directory local variables DLV-ALIST."
  (let ((func.name "dlv//mode/vars.get"))
    (if (not (dlv//validate/mode.symbol func.name mode :error))
        (error "%s: `mode' must be a symbol! %S"
               func.name
               mode))

    (alist-get mode dlv-alist)))
;; (let ((alist '((nil . ((indent-tabs-mode . t)
;;                        (fill-column . 80)
;;                        (mode . auto-fill)))
;;                (c-mode . ((c-file-style . "BSD")
;;                           (subdirs . nil)))
;;                ("src/imported"
;;                 . ((nil . ((change-log-default-name
;;                             . "ChangeLog.local"))))))))
;;   (dlv//mode/vars.get 'c-mode alist))
;;
;; (dlv//mode/vars.get 'c-mode (dlv//mode.create 'c-mode (list (dlv//vars/pair.create 'jeff/var '(:ns-jeff 42 "docstr")))))


(defun dlv//mode/entry.create (mode vars)
  "Create a mode/variables pair for the directory local variables list.

MODE should be an Emacs mode symbol or nil for global mode (all modes)."
  (let ((func.name "dlv//mode/entry.create"))
    (cond ((not (dlv//validate/mode.symbol func.name mode :error))
           (error "%s: `mode' must be a symbol! %S"
                  func.name
                  mode))

          ((not (dlv//validate/dlv.vars func.name vars :error))
           (error "%s: `mode' must be a symbol! %S"
                  func.name
                  mode))

          ;; Valid - create the mode structure.
          (t
           ;; Create just the alist assoc/pair/entry/whatever of this mode and its vars.
           (cons mode
                 vars)))))
;; (dlv//mode/entry.create 'c-mode (dlv//vars/create (dlv//vars/pair.create 'jeff/var '(:ns-jeff 42 "docstr"))))


(defun dlv//mode/set (mode-entry dlv)
  "Set the MODE-ENTRY's entry into the DLV.

The DLV alist should be a certain format, which `dlv//create' returns.

Returns the updated DLV alist."
  (let ((func.name "dlv//mode/set"))
    (cond ((not (dlv//validate/mode.entry func.name mode-entry :error))
           (error "%s: `mode-entry' must be valid! %S"
                  func.name
                  mode-entry))

          ;; Not in DLV alist so just add it.
          ((eq :mode-not-found
               (alist-get (car mode-entry) dlv :mode-not-found))
           (push mode-entry dlv))

          ;; Update it in the alist.
          (t
           (setf (alist-get (car mode-entry) dlv) (cdr mode-entry)))))

  dlv)
;; (dlv//mode/set (dlv//mode/entry.create 'c-mode (dlv//vars/create (dlv//vars/pair.create 'jeff/var '(:ns-jeff 42 "docstr")))) '((nil . ((a . t) (b . "hello")))))
;; (dlv//mode/set (dlv//mode/entry.create 'c-mode (dlv//vars/create (dlv//vars/pair.create 'jeff/var '(:ns-jeff 42 "docstr")))) '((c-mode . ((a . t) (b . "hello")))))


;;------------------------------
;; Directories
;;------------------------------

(defun dlv//dir/entry.create (directory dlv.modes)
  "Create a directory DLV entry for DIRECTORY with the DLV.MODES provided."
  (let* ((func.name "dlv//dir/entry.create")
         (path (dlv//validate/dir.path func.name directory :error)))

    (dolist (mode.entry dlv.modes)
      (if (not (dlv//validate/mode.entry func.name mode.entry :error))
           ;; Should have errored out but:
           (error "%s: `dlv.modes' must be valid! %S"
                  func.name
                  mode.entry)))

    (if (not path)
        ;; Should have errored out but:
        (error "%s: `directory' must be valid! %S"
               func.name
               directory)

      ;; Valid - create the entry.
      (cons directory dlv.modes))))
;; (dlv//dir/entry.create "/foo/bar" (dlv//create (dlv//mode/entry.create 'c-mode (dlv//vars/create (dlv//vars/pair.create  'jeff/var '(:ns-jeff 42 "docstr"))))))
;; '("/foo/bar" . ((c-mode . ((jeff/var :ns-jeff 42 "docstr")))))
;;   -> ("/foo/bar" (c-mode (jeff/var :ns-jeff 42 "docstr")))


;;------------------------------------------------------------------------------
;; Entire DLV Class Structure
;;------------------------------------------------------------------------------

(defun dlv//create (entry)
  "Create a DLV alist from the DLV (mode or dir) ENTRY."
  (let ((func.name "dlv//create"))
    (if (not (or (dlv//validate/mode.entry func.name entry) ;; No erroring.
                 (dlv//validate/dir.entry func.name entry))) ;; No erroring.
        (error "%s: `entry' must be a valid mode or directory DLV entry! %S"
               func.name
               entry)
      ;; Valid entry - turn it into an alist.
      (list entry))))
;; (dlv//create (dlv//dir/entry.create "/foo/bar" (dlv//create (dlv//mode/entry.create 'c-mode (dlv//vars/create (dlv//vars/pair.create  'jeff/var '(:ns-jeff 42 "docstr"))))))
;; (dlv//create (dlv//mode/entry.create 'c-mode (dlv//vars/create (dlv//vars/pair.create 'jeff/var '(:ns-jeff 42 "docstr")))))


;;------------------------------------------------------------------------------
;; DLV API
;;------------------------------------------------------------------------------

(defun dlv//set/directory-class (caller dlv.class dlv.directory dlv.struct)
  "Set DLV structure as CLASS for DIRECTORY.

Does no error checking/validation."
  ;; Set the class of dlv variables and apply it to the directory.
  (dlv//debug caller "Setting class variables `%S': %s" dlv.class dlv.struct)
  (dir-locals-set-class-variables dlv.class dlv.struct)
  (dlv//debug caller "Setting dir class `%S': %s" dlv.class dlv.directory)
  (dir-locals-set-directory-class dlv.directory dlv.class)
  (dlv//debug caller "Getting dir class via `dir-locals-get-directory-class':\n  %S"
              (dir-locals-get-class-variables dlv.class))

  ;; Return something?
  dlv.class)


(defun dlv/set (class directory mode &rest tuples)
  "Create/overwrite a Directory-Local-Variable (DLV).

CLASS should be the name of a symbol for creating the
`dir-locals-set-class-variables'.
You can use `dlv/key.create' to create the DLV key:
  (dlv/key.create namespace class symbol)

DIRECTORY should be the absolute path to the desired directory.

MODE should be the mode the DLV applies to, or `nil' for global mode.

TUPLES should be an alist of '(symbol value safe) tuples.
  - symbol - the symbol to set as a DLV
  - value  - the symbol's directory local value
  - safe   - a predicate function or `t'/`:safe'
    + If a function, store that predicate in the symbol's `safe-local-variable'
      slot for Emacs to use.
    + If `t' or `:safe', do nothing; symbol is assumed to be already marked safe
      for Directory Local Value use."
  (let ((func.name "dlv/set"))
    (dlv//debug func.name
                (concat "Inputs:\n"
                        "  class:     %S\n"
                        "  directory: %S\n"
                        "  mode:      %S\n"
                        "  tuples:     %S\n")
                class
                directory
                mode
                tuples)

    ;;------------------------------
    ;; Validate inputs.
    ;;------------------------------
    ;; Some inputs will be validate when building the DLV structure, so just validate the rest.

    (unless (dlv//validate/class.symbol func.name class :error)
      (error "%s: CLASS must be valid! Got: %S"
             func.name class))
    (unless (dlv//validate/dir.path func.name directory :error)
      (error "%s: DIRECTORY must be valid! Got: %S"
             func.name directory))

    ;; MODE, TUPLES validated in `let*', below.

    ;;------------------------------
    ;; Make the DLV.
    ;;------------------------------

    ;; Create the struct for the DLV.
    (let* ((dlv.vars (apply #'dlv//vars/create tuples))
           (dlv.mode (dlv//mode/entry.create mode dlv.vars))
           (dlv.class class)
           (dlv.directory directory))
      (dlv//debug func.name
                  (concat "DLV'd:\n"
                          "  dlv.class:     %S\n"
                          "  dlv.directory: %S\n"
                          "  dlv.mode:      %S\n")
                  dlv.class
                  dlv.directory
                  dlv.mode)

      ;; Set the class of dlv variables and apply it to the directory.
      (dlv//set/directory-class func.name dlv.class dlv.directory dlv.mode))))
;; (let ((dir (jerky/get "path/org/journal" :namespace :work)))
;;   (dlv/set 'org-journal
;;                  dir
;;                  'org-journal-mode
;;                  'org-journal-dir
;;                  "path/org/journal"
;;                  :namespace :work
;;                  :value dir
;;                  :docstr "jDLV for Org-Journal directory"
;;                  :dlv 'full))


;; ;;------------------------------------------------------------------------------
;; ;; The End.
;; ;;------------------------------------------------------------------------------
;; (imp:provide:with-emacs :jerky 'dlv)
