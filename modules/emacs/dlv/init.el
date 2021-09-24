;;; emacs/dlv/init.el -*- lexical-binding: t; -*-

;;------------------------------
;; NOTE: Namespaces
;;---
;; dlv has three 'namespace' prefixes:
;;   `dlv:'       - public/API functions, variables, etc
;;   `int<dlv>:'  - private/internal functions, variables, etc
;;   `test<dlv>:' - Emacs ERT functions, variables, etc
;;------------------------------


;;------------------------------------------------------------------------------
;; Directory Local Variables
;;------------------------------------------------------------------------------

(require 's)
(require 'dash)

;;------------------------------------------------------------------------------
;; Constants
;;------------------------------------------------------------------------------

(defconst int<dlv>:const:class:prefix "dlv:class"
  "Used to create DLV class symbols in `int<dlv>:class:symbol.create'.")

(defconst int<dlv>:const:class:separator "://"
  "Used to create DLV class symbols in `int<dlv>:class:normalize.str' and
`int<dlv>:class:normalize.all'.")

(defconst int<dlv>:const:normalize:separator "/"
  "Used to create DLV class symbols in `int<dlv>:class:normalize.all'.")

(defconst int<dlv>:const:safe.valid '(:safe t)
  "Valid constant values for `safe' in `dlv:set'.")


;;------------------------------------------------------------------------------
;; Debugging Help
;;------------------------------------------------------------------------------

(defvar int<dlv>:debug/enabled? nil
  "Debug flag.")


(defun int<dlv>:debug:toggle ()
  "Toggle debugging for DLV."
  (interactive)
  (setq int<dlv>:debug/enabled? (not int<dlv>:debug/enabled?))
  (message "DLV debugging: %s"
           (if int<dlv>:debug/enabled?
               "enabled"
             "disabled")))


(defun int<dlv>:debug (func msg &rest args)
  "Print out a debug message if debugging."
  (when int<dlv>:debug/enabled?
    (apply #'message
           (concat func ": " msg)
           args)))
;; (int<dlv>:debug "test")


;;------------------------------------------------------------------------------
;; DLV Directory Path
;;------------------------------------------------------------------------------

(defun int<dlv>:dir:normalize (dir)
  "Normalize DIR into an absolute path with '/' separators and ending in a '/'.

Example:
  (int<dlv>:dir:normalize \"D:\\foo\\bar\")
    -> \"d:/foo/bar/\""
  ;; Finish by ensuring we have a trailing '/'.
  (file-name-as-directory
   ;; `expand-file-name' lowercases Windows drive letters and converts backslash to forwardslash.
   (expand-file-name dir)))


;;------------------------------------------------------------------------------
;; DLV Class Symbol Creation
;;------------------------------------------------------------------------------

(defun int<dlv>:class:normalize.prefix (str)
  "Remove unwanted prefixes from STR."
  (replace-regexp-in-string
   (rx string-start (one-or-more (any ":" "/" "\\")))
   ""
   str))
;; (int<dlv>:class:normalize.prefix "://hi")
;; (int<dlv>:class:normalize.prefix "greet://hi")


(defun int<dlv>:class:normalize.str (str)
  "Normalize a string."
  (if (string= str int<dlv>:const:class:separator)
      ;; Allow special strings through even if they aren't "valid".
      str

    ;; Fix any undesired prefixes.
    (int<dlv>:class:normalize.prefix
     ;; NOTE: Should we replace tilde (~)? It's valid in a symbol name,
     ;; e.g. (setq ~/test 42)

     ;; backslash -> slash
     (replace-regexp-in-string
      (rx "\\")
      "/"
      ;; Delete any control chars.
      (replace-regexp-in-string
       (rx (one-or-more control))
       ""
       str)))))
;; As-is:
;;   (int<dlv>:class:normalize.str "jeff")
;;   (int<dlv>:class:normalize.str "d:/foo")
;; A backslash:
;;   (int<dlv>:class:normalize.str "d:\\foo")
;; A control character:
;;   (int<dlv>:class:normalize.str "d:\foo")


(defun int<dlv>:class:normalize.any (arg)
  "Figure out whan to do to normalize ARG into a str for use as a DLV
class symbol."
  ;; Convert to a string, then use `int<dlv>:class:normalize.str'.
  (int<dlv>:class:normalize.str
   (cond ((null arg)
          ;; Empty string for nil?
          "")

         ((stringp arg)
          arg)

         ((symbolp arg)
          (symbol-name arg))

         ((functionp arg)
          (format "%s" (funcall arg)))

         ;; Fail - don't want to be crazy and blindly convert something.
         (t
          (error "%s: Can't convert ARG '%S' to string for creating a class symbol."
                 "int<dlv>:class:normalize.any"
                 arg)))))
;; (int<dlv>:class:normalize.any :foo/bar)


(defun int<dlv>:class:normalize.all (args)
  "Turn args into a key string.

(int<dlv>:key.normalize '(\"a/b\" \"c\"))
  -> a/b/c
(int<dlv>:key.normalize '(\"a/b\" c))
  -> a/b/c
(int<dlv>:key.normalize '(\"a\" b c))
  -> a/b/c"
  ;; Nuke `int<dlv>:const:normalize:separator' for special args.
  (replace-regexp-in-string
   (rx-to-string (list 'sequence
                       int<dlv>:const:normalize:separator
                       int<dlv>:const:class:separator
                       int<dlv>:const:normalize:separator)
                 :no-group)
   int<dlv>:const:class:separator

   ;; Combine all the normalized args w/ our separator.
   (string-join
    (if (listp args)
        ;; Normalize a list:
        (-filter (lambda (x) (not (null x))) ;; Ignore nils from conversion.
                 ;; Convert a list of whatever into a list of strings.
                 (-map #'int<dlv>:class:normalize.any args))
      ;; Normalize a thing into a list of string:
      (list (funcall #'int<dlv>:class:normalize.any args)))
    int<dlv>:const:normalize:separator)))
;; (int<dlv>:class:normalize.all "hi")
;; (int<dlv>:class:normalize.all 'hi)
;; (int<dlv>:class:normalize.all '(h i))
;; (int<dlv>:class:normalize.all '(:h :i))
;; (int<dlv>:class:normalize.all (list :hello int<dlv>:const:class:separator :there))


(defun int<dlv>:class:symbol.build (&rest args)
  "Create a DLV 'class' symbol from ARGS.

ARGS can be a path, strings, symbols, functions...
  - Functions should take no args and return a string.
  - Can use `int<dlv>:const:class:separator' to split up e.g. symbol and path."
  ;; Use `intern' instead of `make-symbol' so we can assert thing easier in ERT unit tests.
  ;; Fun fact: `make-symbol' keywords are not `eq' to each other?! I thought keywords were unique in that they were constant but I guess if
  ;; not in the object array they're not keywords.
  ;;   (eq (make-symbol ":foo") (make-symbol ":foo"))
  (intern
   (int<dlv>:class:normalize.all args)))
;; (int<dlv>:class:symbol.build 'org-class 'org-journal)
;; (int<dlv>:class:symbol.build 'org-journal)
;; (int<dlv>:class:symbol.build 'org-journal-dir)
;; (int<dlv>:class:symbol.build "D:\\foo\\bar")
;; (int<dlv>:class:symbol.build "~/foo/bar")


(defun int<dlv>:class:symbol.create (dir.normalized)
  "Create a DLV 'class' symbol for the DIR.NORMALIZED path.

DIR.NORMALIZED should be:
  - A path string.
  - A return value from `int<dlv>:dir:normalize'.

Uses `int<dlv>:const:class:separator' to split up const prefix string and path."
  (int<dlv>:class:symbol.build int<dlv>:const:class:prefix
                               int<dlv>:const:class:separator
                               dir.normalized))
;; (int<dlv>:class:symbol.create (int<dlv>:dir:normalize "D:\\foo\\bar"))
;; (int<dlv>:class:symbol.create (int<dlv>:dir:normalize "~/foo/bar"))


;;------------------------------------------------------------------------------
;; Validation
;;------------------------------------------------------------------------------

;;------------------------------
;; Variables
;;------------------------------

(defun int<dlv>:validate:safe (caller safe &optional signal-error)
  "Check that SAFE param is valid for CALLER (probably `dlv:set')."
  (int<dlv>:debug "int<dlv>:validate:safe"
                  (concat "Inputs:\n"
                          "  caller: %s\n"
                          "  safe: %S\n"
                          "  error?: %S")
                  caller safe signal-error)
  (int<dlv>:debug "int<dlv>:validate:safe"
                  (concat "`safe' is:\n"
                          "  functionp: %s\n"
                          "  memq %S: %s")
                  (functionp safe)
                  int<dlv>:const:safe.valid
                  (memq safe int<dlv>:const:safe.valid))

  (cond ((or (functionp safe)
             (memq safe int<dlv>:const:safe.valid))
         t)

        ((not (null signal-error))
         (error (concat "%s: Invalid SAFE value; must be a function or one of:"
                        "%S. "
                        "Got: %S. "
                        "functionp: %S, memq: %S")
                caller
                int<dlv>:const:safe.valid
                safe
                (functionp safe)
                (memq safe int<dlv>:const:safe.valid)))

        ;; Invalid, but no signaling - return nil.
        (t
         nil)))


(defun int<dlv>:validate:var.symbol (caller symbol &optional signal-error)
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


(defun int<dlv>:validate:var.value (caller value &optional signal-error)
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

(defun int<dlv>:validate:var.pair (caller pair &optional signal-error)
  "Check that PAIR is a valid 2-tuple of a symbol and something for DLVs."
  ;; Must be a 2-tuple, so cons is good.
  ;; If it's a list of the correct length, convert to a cons.
  (cond ((and (consp pair)
              (int<dlv>:validate:var.symbol caller (car pair) signal-error)
              (int<dlv>:validate:var.value  caller (cdr pair) signal-error))
         pair)

        ((and (listp pair)
              (= (length pair) 2)
              (int<dlv>:validate:var.symbol caller (nth 0 pair) signal-error)
              (int<dlv>:validate:var.value  caller (nth 1 pair) signal-error))
         ;; Convert to cons.
         (cons (nth 0 pair)
               (nth 1 pair)))

        ;; Nope.
        (t
         (if (not (null signal-error))
             (error "%s: Failed validation: Pair must be a valid 2-tuple of a symbol and a value. Got: %S"
                    caller pair)
           nil))))


(defun int<dlv>:validate:dlv.vars (caller dlv.vars &optional signal-error)
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
        (if (not (int<dlv>:validate:var.pair caller pair signal-error))
            (if (not (null signal-error))
                ;; Should have already errored, but just in case:
                (error "%s: `pair' failed validation! %S"
                       caller pair)
              ;; Don't error - just set our success/failure value.
              (setq valid nil)))))
    ;; Return our validation summary.
    valid))


;;------------------------------
;; Mode
;;------------------------------

(defun int<dlv>:validate:mode.symbol (caller mode &optional signal-error)
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


(defun int<dlv>:validate:mode.entry (caller mode.entry &optional signal-error)
  "Checks that MODE.ENTRY is valid for a DLV mode.

Must be a cons with a valid mode and valid vars."
  (cond ((and (consp mode.entry)
              (int<dlv>:validate:mode.symbol caller (car mode.entry) signal-error)
              (int<dlv>:validate:dlv.vars caller (cdr mode.entry) signal-error))
         t)

        ;; Invalid - error or return nil.
        ((not (null signal-error))
         ;; Probably wasn't a cons, since the rest should've errored in their funcs.
         (error "%s: `mode.entry' is not valid! Must be a cons with valid members. %S"
                caller
                mode))

        (t
         nil)))


;;------------------------------
;; Class Symbol
;;------------------------------

(defun int<dlv>:validate:class.symbol (caller class &optional signal-error)
  "Check that CLASS is valid for CALLER (probably `dlv:set')."
  (cond ((symbolp class)
         t)

        ((not (null signal-error))
         (error "%s: Invalid CLASS value; must be a symbol: %S. Got: %S"
                caller
                int<dlv>:const:safe.valid
                safe))

        ;; Invalid, but no signaling - return nil.
        (t
         nil)))


;;------------------------------
;; Directories
;;------------------------------

(defun int<dlv>:validate:dir.path (caller path &optional signal-error)
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
;; (int<dlv>:validate:dir.path "test" "relative/path/file" :error)
;; (int<dlv>:validate:dir.path "test" "relative/path/" :error)
;; Ok, updated:
;; (int<dlv>:validate:dir.path "test" "c:/absolute/path/no-slash" :error)
;; Good:
;; (int<dlv>:validate:dir.path "test" user-emacs-directory :error)
;; (int<dlv>:validate:dir.path "test" "~/" :error)
;; (int<dlv>:validate:dir.path "test" "c:/absolute/path/slash/" :error)


(defun int<dlv>:validate:dir.entry (caller dir.entry &optional signal-error)
  "Checks that DIR.ENTRY is valid for a DLV mode.

Must be a cons with a valid path and valid mode entries."
  (let ((valid t))
    (cond ((and (consp dir.entry)
                (int<dlv>:validate:dir.path caller (car dir.entry) signal-error))
           ;; Path is valid. Check all the entries.
           (dolist (mode.entry (cdr dir.entry))
             (unless (int<dlv>:validate:mode.entry caller mode.entry signal-error)
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


;;------------------------------
;; Full DLV Structure
;;------------------------------

(defun int<dlv>:validate:dlv (caller dlv &optional signal-error)
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
                     (or (int<dlv>:validate:dir.entry caller dir-or-mode.entry signal-error)
                         (int<dlv>:validate:mode.entry caller dir-or-mode.entry signal-error)))
                   dlv)))
    ;; Return the summary.
    valid))


;;------------------------------
;; Emacs Dir Locals
;;------------------------------

(defun int<dlv>:validate:emacs.dlv:dir.path (caller path &optional signal-error)
  "Checks that PATH is not an emacs DLV path yet."
  (let ((path (expand-file-name path)))
    ;; NOTE: Do not use `dir-locals-find-file' - it will give you a dir's parents' DLVs and that's a false positive (probably?).
    (if (assoc path dir-locals-directory-cache)
        ;; Already exists in dir-locals - so we can't create another one here.
        (if (not (null signal-error))
            (error "%s(%S): `path' is already in Emacs dir-locals! %S"
                   caller
                   signal-error
                   path)
          ;; Don't want an error, so just return false.
          nil)

      ;; Return something truthy. We expanded the path, so maybe that?
      path)))


;;------------------------------------------------------------------------------
;; Mark as Safe for DLV
;;------------------------------------------------------------------------------

(defun int<dlv>:vars:safe (caller symbol validation-predicate)
  "Mark SYMBOL as a safe directory local variable as long as the
(directory-local) value passes the VALIDATION-PREDICATE.

If VALIDATION-PREDICATE is a member of `int<dlv>:const:safe.valid', does nothing.

If VALIDATION-PREDICATE is something else, raises an error signal."
  (let ((func.name "int<dlv>:vars:safe"))
    (int<dlv>:debug func.name
                    (concat "Inputs:\n"
                            "  caller:               %S\n"
                            "  symbol:               %S\n"
                            "  validation-predicate: %S")
                    caller
                    symbol
                    validation-predicate)

    (if (int<dlv>:validate:safe caller validation-predicate :error)
        ;; If it /is/ a member of `int<dlv>:const:safe.valid', we don't need to do anything.
        (if (memq validation-predicate int<dlv>:const:safe.valid)
            (progn
              ;; If it /is/ a member of `int<dlv>:const:safe.valid', we don't need to do anything.
              (int<dlv>:debug func.name "symbol %S already safe: %S"
                              symbol
                              validation-predicate)
              ;; Just rerturn something?
              validation-predicate)

          (int<dlv>:debug func.name "Setting symbol %S `safe-local-variable' slot to: %S"
                          symbol
                          validation-predicate)
          ;; Add the VALIDATION-PREDICATE function to the SYMBOL's `safe-local-variable' property.
          (prog1
              (put symbol 'safe-local-variable validation-predicate)

            (int<dlv>:debug func.name "Symbol %S `safe-local-variable' slot is now: %S"
                            symbol
                            (get symbol 'safe-local-variable))))

      ;; Else not a valid VALIDATION-PREDICATE or 'already safe' const.
      ;; Probably already error, but to be safe:
      (error "%s: Cannot mark symbol %S as safe. VALIDATION-PREDICATE was not valid: %S"
             caller
             symbol
             validation-predicate))))
;; (makunbound 'test/local)
;; (setq test/local t)
;; (get 'test/local 'safe-local-variable)
;; (int<dlv>:vars:safe "test-00" 'test/local 'boundp)
;; (get 'test/local 'safe-local-variable)
;;
;; (put 'test/local 'safe-local-variable nil)
;; (makunbound 'test/local)
;; (setq test/local t)
;; (int<dlv>:vars:safe "test-01" 'test/local :safe)
;; (get 'test/local 'safe-local-variable)


(defun dlv:var:safe.predicate (symbol predicate)
  "Mark SYMBOL as safe using PREDICATE function for
Directory Local Variables."
  (if (not (functionp predicate))
      (error "dlv:var:safe.predicate: Cannot mark SYMBOL (%S) as safe; PREDICATE is not a function? %S"
             symbol
             predicate)
    (int<dlv>:vars:safe "dlv:var:safe.function" symbol predicate)))


(defun dlv:var:safe.value (symbol value)
  "Add SYMBOL and VALUE as a known-safe combination for
Directory Local Variables."
  (push (cons symbol value) safe-local-variable-values))


;;------------------------------------------------------------------------------
;; DLV structures
;;------------------------------------------------------------------------------

;;------------------------------
;; Variables
;;------------------------------

(defun int<dlv>:vars:pair.create (symbol value safe)
  "Create the key/value pair from SYMBOL and VALUE for a variable for the
directory local variables list.

Mark symbol as safe-for-DLV via predicate function if SAFE is a function.
Do nothing if SAFE is a member of `int<dlv>:const:safe.valid'.
Error otherwise."
  (let ((func.name "int<dlv>:vars:pair.create"))
    (int<dlv>:debug func.name
                    (concat "Inputs:\n"
                            "  symbol: %S\n"
                            "  value:  %S\n"
                            "  safe:   %S")
                    symbol
                    value
                    safe)

    (if (not (and (int<dlv>:validate:var.symbol func.name symbol :error)
                  (int<dlv>:validate:var.value func.name value :error)
                  (int<dlv>:validate:safe func.name safe :error)))
        (error "%s: Failed to validate SYMBOL, VALUE, and/or SAFE! %S %S %S"
               func.name
               symbol value safe)
      ;; Mark SYMBOL with SAFE, then create/return the var pair.
      (int<dlv>:vars:safe func.name symbol safe)
      (cons symbol
            value))))
;; (int<dlv>:vars:pair.create 'jeff/var '(:ns-jeff 42 "docstr") :safe)


;;---
;; NOTE: Commented out until this is needed or at least tested.
;;---
;; (defun int<dlv>:vars:pair.get (symbol dlv.vars)
;;   "Get the symbol SYMBOL from the directory local variables DLV.VARS.
;;
;; If QUIET is not nil, signals error. Else returns nil on error."
;;   (let ((func.name "int<dlv>:vars:pair.get"))
;;     (unless (int<dlv>:validate:var.symbol func.name symbol :error)
;;       (error "%s: `symbol' failed validation! %S"
;;              "int<dlv>:pair.get" symbol))
;;     (alist-get symbol dlv.vars)))
;; ;; (int<dlv>:vars:pair.get 'jeff '((jill . "hello there") (jeff . 42)))


(defun int<dlv>:vars:pair.set (pair dlv.vars)
  "Updates or adds the PAIR entry into the variables DLV.VARS.

PAIR should be a certain format, which `int<dlv>:pair.create' returns.

Returns the updated alist."
  (let ((func.name "int<dlv>:vars:pair.set"))
    (if (not (int<dlv>:validate:var.pair func.name pair :error))
        ;; Should have already errored, but just in case:
        (error "%s: `pair' failed validation! %S"
               func.name pair)

      ;; Valid - set/update the var in the alist.
      (if (null (assoc (car pair) dlv.vars))
          (push pair dlv.vars)
        (setf (alist-get (car pair) dlv.vars) (cdr pair)))
      dlv.vars)))
;; (let ((an-alist '((baz . qux)))) (int<dlv>:vars:pair.set '(foo . bar) an-alist))
;; (let ((an-alist '((foo . foo) (baz . qux)))) (int<dlv>:vars:pair.set '(foo . bar) an-alist))


(defun int<dlv>:vars:create (&rest tuples)
  "Create the key/value tuples for supplying to e.g. `int<dlv>:mode:entry.create'.

TUPLES must be an alist of 3-tuples of: (symbol value safe).
  - SYMBOL must be a symbol.
  - VALUE can be anything.
  - SAFE must be a function or one of: (t :safe)
    + If a function, will set symbol's `safe-local-variable' slot to that function. "
  (let ((func.name "int<dlv>:vars:create"))
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
              (push (int<dlv>:vars:pair.create (nth 0 tuple)
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
;; (int<dlv>:vars:create '(one "one" :safe) '(two "two" boundp))


;;------------------------------
;; Modes
;;------------------------------

(defun int<dlv>:mode:entry.create (mode vars)
  "Create a mode/variables pair for the directory local variables list.

MODE should be an Emacs mode symbol or nil for global mode (all modes)."
  (let ((func.name "int<dlv>:mode:entry.create"))
    (cond ((not (int<dlv>:validate:mode.symbol func.name mode :error))
           (error "%s: `mode' must be a symbol! %S"
                  func.name
                  mode))

          ((not (int<dlv>:validate:dlv.vars func.name vars :error))
           (error "%s: `mode' must be a symbol! %S"
                  func.name
                  mode))

          ;; Valid - create the mode structure.
          (t
           ;; Create just the alist assoc/pair/entry/whatever of this mode and its vars.
           (cons mode
                 vars)))))
;; (int<dlv>:mode:entry.create 'c-mode (int<dlv>:vars:create '(jeff/var (:ns-jeff 42 "docstr") :safe)))


(defun int<dlv>:mode:vars.get (mode dlv-alist)
  "Get the MODE's alist of variables from the directory local variables DLV-ALIST."
  (let ((func.name "int<dlv>:mode:vars.get"))
    (if (not (int<dlv>:validate:mode.symbol func.name mode :error))
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
;;   (int<dlv>:mode:vars.get 'c-mode alist))
;;
;; (int<dlv>:mode:vars.get 'c-mode (int<dlv>:struct:create (int<dlv>:mode:entry.create 'c-mode (int<dlv>:vars:create '(jeff/var 42 :safe)))))


(defun int<dlv>:mode:set (mode-entry dlv)
  "Set the MODE-ENTRY's entry into the DLV.

The DLV alist should be a certain format, which `int<dlv>:struct:create' returns.

Returns the updated DLV alist."
  (let ((func.name "int<dlv>:mode:set"))
    (cond ((not (int<dlv>:validate:mode.entry func.name mode-entry :error))
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
;; (int<dlv>:mode:set (int<dlv>:mode:entry.create 'c-mode (int<dlv>:vars:create '(jeff/var 42 :safe))) '((nil . ((a . t) (b . "hello")))))
;; (int<dlv>:mode:set (int<dlv>:mode:entry.create 'c-mode (int<dlv>:vars:create '(jeff/var 42 :safe))) '((c-mode . ((a . t) (b . "hello")))))


;;------------------------------
;; Directories
;;------------------------------

(defun int<dlv>:dir:entry.create (directory dlv.modes)
  "Create a directory DLV entry for DIRECTORY with the DLV.MODES provided."
  (let* ((func.name "int<dlv>:dir:entry.create")
         (path (int<dlv>:validate:dir.path func.name directory :error)))

    (dolist (mode.entry dlv.modes)
      (if (not (int<dlv>:validate:mode.entry func.name mode.entry :error))
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
;; (int<dlv>:dir:entry.create "/foo/bar" (int<dlv>:struct:create (int<dlv>:mode:entry.create 'c-mode (int<dlv>:vars:create (int<dlv>:vars:pair.create  'jeff/var '(:ns-jeff 42 "docstr"))))))
;; '("/foo/bar" . ((c-mode . ((jeff/var :ns-jeff 42 "docstr")))))
;;   -> ("/foo/bar" (c-mode (jeff/var :ns-jeff 42 "docstr")))


;;------------------------------------------------------------------------------
;; Entire DLV Class Structure
;;------------------------------------------------------------------------------

(defun int<dlv>:struct:create (entry)
  "Create a DLV alist from the DLV (mode or dir) ENTRY."
  (let ((func.name "int<dlv>:struct:create"))
    (if (not (or (int<dlv>:validate:mode.entry func.name entry) ;; No erroring.
                 (int<dlv>:validate:dir.entry func.name entry))) ;; No erroring.
        (error "%s: `entry' must be a valid mode or directory DLV entry! %S"
               func.name
               entry)
      ;; Valid entry - turn it into an alist.
      (list entry))))
;; (int<dlv>:struct:create (int<dlv>:dir:entry.create "/foo/bar" (int<dlv>:struct:create (int<dlv>:mode:entry.create 'c-mode (int<dlv>:vars:create (int<dlv>:vars:pair.create  'jeff/var '(:ns-jeff 42 "docstr"))))))
;; (int<dlv>:struct:create (int<dlv>:mode:entry.create 'c-mode (int<dlv>:vars:create (int<dlv>:vars:pair.create 'jeff/var '(:ns-jeff 42 "docstr")))))


(defun int<dlv>:exists? (directory &optional class)
  "Does the dir-locals CLASS exist for this DIRECTORY?

Builds the class symbol using DIRECTORY & `int<dlv>:class:symbol.create'
if CLASS is nil."
  (not (null (dir-locals-get-class-variables
              (or class
                  (int<dlv>:class:symbol.create (int<dlv>:dir:normalize directory)))))))


;;------------------------------------------------------------------------------
;; DLV API
;;------------------------------------------------------------------------------

(defun int<dlv>:directory-class.create (caller dlv.class dlv.directory dlv.struct)
  "Set DLV.STRUCT structure as CLASS for DIRECTORY.

Does no error checking/validation."
  ;; Set the class of dlv variables and apply it to the directory.
  (int<dlv>:debug caller "Setting class variables `%S': %s" dlv.class dlv.struct)
  (dir-locals-set-class-variables dlv.class dlv.struct)
  (int<dlv>:debug caller "Setting dir class `%S': %s" dlv.class dlv.directory)
  (dir-locals-set-directory-class dlv.directory dlv.class)
  (int<dlv>:debug caller "Getting dir class via `dir-locals-get-directory-class':\n  %S"
                  (dir-locals-get-class-variables dlv.class))

  ;; Return something?
  dlv.class)


(defun int<dlv>:directory-class.update (caller dlv.class dlv.struct)
  "Update the DLV.STRUCT structure CLASS.

Does no error checking/validation."
  ;; Only set the class -> dlv variables. Directory -> class should already exist.
  (int<dlv>:debug caller "Setting class variables `%S': %s" dlv.class dlv.struct)
  (dir-locals-set-class-variables dlv.class dlv.struct)
  (int<dlv>:debug caller "Getting dir class via `dir-locals-get-directory-class':\n  %S"
                  (dir-locals-get-class-variables dlv.class))

  ;; Return something?
  dlv.class)


(defun dlv:create (directory mode &rest tuples)
  "Create a Directory-Local-Variable (DLV) class.

DIRECTORY should be the absolute path to the desired directory.

MODE should be the mode the DLV applies to, or `nil' for global mode.

TUPLES should be an alist of '(symbol value safe) tuples.
  - symbol - the symbol to set as a DLV
  - value  - the symbol's directory local value
  - safe   - a predicate function or `t'/`:safe'
    + If a function, store that predicate in the symbol's `safe-local-variable'
      slot for Emacs to use.
    + If `t' or `:safe', do nothing; symbol is assumed to be already marked safe
      for Directory Local Value use.

Emacs DLV's 'class' symbol for the directory will be created to be:
  (int<dlv>:class:symbol.create (int<dlv>:dir:normalize DIRECTORY))

example for \"d:\\foo\\bar\":
  (int<dlv>:class:symbol.create (int<dlv>:dir:normalize \"d:\\foo\\bar\"))
    -> dlv:class://d:/foo/bar/"
  (let* ((func.name "dlv:create")
         (directory (int<dlv>:dir:normalize directory))
         (dlv.class (int<dlv>:class:symbol.create directory)))
    (int<dlv>:debug func.name
                    (concat "Inputs:\n"
                            "  directory: %S\n"
                            "  mode:      %S\n"
                            "  tuples:     %S")
                    ;; "  symbol:    %S\n"
                    ;; "  value:     %S")
                    directory
                    mode
                    tuples)

    ;;------------------------------
    ;; Validate inputs.
    ;;------------------------------
    ;; Some inputs will be validate when building the DLV structure, so just validate the rest.

    (unless (int<dlv>:validate:class.symbol func.name dlv.class :error)
      (error "%s: `dlv.class' must be valid! Got: %S"
             func.name dlv.class))
    (unless (int<dlv>:validate:dir.path func.name directory :error)
      (error "%s: DIRECTORY must be valid! Got: %S"
             func.name directory))
    ;; Creating, so don't allow if one already exists for the dir.
    (unless (int<dlv>:validate:emacs.dlv:dir.path "int<dlv>:dir:entry.create" directory :error)
      (error "%s: Cannot create entry for directory; Emacs DLV already exists for it. DIRECTORY: '%s'"
             func.name
             directory))

    ;; MODE, TUPLES validated in `let*', below.

    ;;------------------------------
    ;; Make the DLV.
    ;;------------------------------

    ;; Create the struct for the DLV.
    (let* ((dlv.vars (apply #'int<dlv>:vars:create tuples))
           (dlv.mode (int<dlv>:mode:entry.create mode dlv.vars))
           (dlv.struct (int<dlv>:struct:create dlv.mode))
           (dlv.directory directory))
      (int<dlv>:debug func.name
                      (concat "DLV'd:\n"
                              "  dlv.class:     %S\n"
                              "  dlv.directory: %S\n"
                              "  dlv.struct:    %S\n"
                              "   <- dlv.mode:    %S\n"
                              "      <- dlv.vars: %S\n")
                      dlv.class
                      dlv.directory
                      dlv.struct
                      dlv.mode
                      dlv.vars)

      ;; Set the class of dlv variables and apply it to the directory.
      (int<dlv>:directory-class.create func.name dlv.class dlv.directory dlv.struct))))


(defun dlv:update (directory mode &rest tuples)
  "Update an existing Directory-Local-Variable (DLV) class.

DIRECTORY should be the absolute path to the desired directory.

MODE should be the mode the DLV applies to, or `nil' for global mode.

TUPLES should be an alist of '(symbol value safe) tuples.
  - symbol - the symbol to set as a DLV
  - value  - the symbol's directory local value
  - safe   - a predicate function or `t'/`:safe'
    + If a function, store that predicate in the symbol's `safe-local-variable'
      slot for Emacs to use.
    + If `t' or `:safe', do nothing; symbol is assumed to be already marked safe
      for Directory Local Value use.

Emacs DLV's 'class' symbol for the directory will be created to be:
  (int<dlv>:class:symbol.create (int<dlv>:dir:normalize DIRECTORY))

example for \"d:\\foo\\bar\":
  (int<dlv>:class:symbol.create (int<dlv>:dir:normalize \"d:\\foo\\bar\"))
    -> dlv:class://d:/foo/bar/"
  (let* ((func.name "dlv:update")
         (directory (int<dlv>:dir:normalize directory))
         (dlv.class (int<dlv>:class:symbol.create directory))
         (existing/dlv.struct (dir-locals-get-class-variables dlv.class)))
    (int<dlv>:debug func.name
                    (concat "Inputs:\n"
                            "  directory: %S\n"
                            "  mode:      %S\n"
                            "  tuples:     %S")
                    ;; "  symbol:    %S\n"
                    ;; "  value:     %S")
                    directory
                    mode
                    tuples)

    ;;------------------------------
    ;; Validate inputs.
    ;;------------------------------
    ;; Some inputs will be validate when building the DLV structure, so just validate the rest.

    (unless (int<dlv>:validate:class.symbol func.name dlv.class :error)
      (error "%s: `dlv.class' must be valid! Got: %S"
             func.name dlv.class))
    (unless (int<dlv>:validate:dir.path func.name directory :error)
      (error "%s: DIRECTORY must be valid! Got: %S"
             func.name directory))
    ;;---
    ;; Class should already exist.
    ;;---
    ;; Might as well run through path validation... And don't let the validation function
    ;; error, since we want this to 'fail' (return 'already a class for that dir').
    (when (int<dlv>:validate:emacs.dlv:dir.path func.name directory nil)
      (error "%s: Cannot update entry for directory; existing Emacs DLV was not found exists for it. directory: '%s'"
             func.name
             directory))

    ;; Updating, so don't allow if one /does not/ exists for the dir.
    (unless existing/dlv.struct
      (error (concat "%s: Cannot update entry for directory; "
                     "an existing Emacs DLV class was not found for it. "
                     "expected class symbol: %S, "
                     "directory: '%s', "
                     "existing/dlv.struct: %S"
                     func.name
                     dlv.class
                     directory
                     existing/dlv.struct)))

    ;; MODE, TUPLES validated in `let*', below.

    ;;------------------------------
    ;; Update the DLV.
    ;;------------------------------

    ;; Break the existing DLV struct down, so that we can update the new pieces.
    ;; Also create our DLV vars.
    (let* ((existing/dlv.vars (int<dlv>:mode:vars.get mode existing/dlv.struct))
           (dlv.vars (apply #'int<dlv>:vars:create tuples))
           dlv.mode)
      (if existing/dlv.vars
          ;; Add or update vars.
          (progn
            (dolist (kvp dlv.vars)
              (setq existing/dlv.vars
                    (int<dlv>:vars:pair.set kvp existing/dlv.vars)))
            (setq dlv.mode (int<dlv>:mode:entry.create mode dlv.vars)))

        ;; No vars for the mode, so... Create the mode.
        (setq dlv.mode (int<dlv>:mode:entry.create mode dlv.vars)))

      ;; Now that `dlv.vars' is the updated vars, create a new dlv.mode entry for it.
      (setq dlv.mode (int<dlv>:mode:entry.create mode dlv.vars))

      ;; Set the new/updated mode entry into the dlv struct.
      (setq existing/dlv.struct (int<dlv>:mode:set dlv.mode existing/dlv.struct))

      ;; And now we can replace the DLV struct in Emacs.
      (int<dlv>:directory-class.update func.name dlv.class existing/dlv.struct))))


(defun dlv:set (directory mode &rest tuples)
  "Create or update a Directory-Local-Variable (DLV) class.

DIRECTORY should be the absolute path to the desired directory.

MODE should be the mode the DLV applies to, or `nil' for global mode.

TUPLES should be an alist of '(symbol value safe) tuples.
  - symbol - the symbol to set as a DLV
  - value  - the symbol's directory local value
  - safe   - a predicate function or `t'/`:safe'
    + If a function, store that predicate in the symbol's `safe-local-variable'
      slot for Emacs to use.
    + If `t' or `:safe', do nothing; symbol is assumed to be already marked safe
      for Directory Local Value use.

Emacs DLV's 'class' symbol for the directory will be created to be:
  (int<dlv>:class:symbol.create (int<dlv>:dir:normalize DIRECTORY))

example for \"d:\\foo\\bar\":
  (int<dlv>:class:symbol.create (int<dlv>:dir:normalize \"d:\\foo\\bar\"))
    -> dlv:class://d:/foo/bar/"
  (if (int<dlv>:exists? directory)
      (apply #'dlv:update directory mode tuples)
    (apply #'dlv:create directory mode tuples)))


(defun dlv:check (filepath symbol expected)
  "Get SYMBOL's value at FILEPATH in a few different ways."

  (let ((file/existed? (file-exists-p filepath))
        (buffer/existed? (get-file-buffer filepath))
        buffer/local
        value/ffns
        value/blv
        value/slvp)

    ;; These don't work if the file doesn't exist.
    (unwind-protect
        (progn
          (setq buffer/local (get-buffer-create filepath))
          (setq value/blv (buffer-local-value symbol buffer/local))
          (with-current-buffer buffer/local
            (setq value/slvp (safe-local-variable-p symbol expected))))
      (unless buffer/existed?
        (kill-buffer buffer/local))
      (setq buffer/local nil))

    ;; This should always work.
    (unwind-protect
        (progn
          (setq buffer/local (find-file-noselect filepath))
          (with-current-buffer buffer/local
            (setq value/ffns (symbol-value symbol))))
      (unless buffer/existed?
        (kill-buffer buffer/local))
      (unless file/existed?
        (delete-file filepath))
      (setq buffer/local nil))

    ;; Output results.
    (message (concat "dlv:check:\n"
                     "  inputs:\n"
                     "    filepath:                              %s\n"
                     "    symbol: - - - - - - - - - - - - - - -  %S\n"
                     "    EXPECTED: ---------------------------> %S\n"
                     "  values:\n"
                     "    `find-file-noselect':                  %S\n"
                     "    `buffer-local-value': - - - - - - - -  %S\n"
                     "    `safe-local-variable-p':               %S\n"
                     "  info:\n"
                     "    `enable-local-variables': - - - - - -  %S\n"
                     "    symbol property `safe-local-variable': %S\n"
                     "    assoc `safe-local-variable-values':    %S")
             ;; inputs
             filepath
             symbol
             expected
             ;; values
             value/ffns
             value/blv
             value/slvp
             ;; infos
             enable-local-variables
             (get symbol 'safe-local-variable)
             (assoc symbol safe-local-variable-values))))
;; (let* ((dir "~/dlv-test/")
;;        (filename (format "locals-%S.txt" (spy:datetime/string.get 'iso-8601 'file)))
;;        (filepath (concat dir filename))
;;        (class 'int<dlv>:test:class)
;;        (mode nil)
;;        (tuple '(int<dlv>:test:variable :test/local int<dlv>:test:safe-p)))
;;   (dlv:set class dir mode tuple)
;;   (dlv:check filepath 'int<dlv>:test:variable :test/local))


(defun dlv:buffer-locals/show-all ()
  "Show all the buffer-local variables and values for the buffer.

NOTE: Huge alist!"
  (interactive)
  (int<dlv>:message:boxed.xml :start "dlv:buffer-locals/show-all"
                              (cons "buffer" (buffer-name))
                              (cons "path" (buffer-file-name)))
  (message "")

  (pp (buffer-local-variables))

  (message "")
  (int<dlv>:message:boxed.xml :end "dlv:buffer-locals/show-all"))


(defun dlv:buffer-locals/show-dlvs ()
  "Show the dir-local (and file-local) variables and values from the
buffer-local variable alist.

A very much reduced list from `dlv:buffer-locals/show-all'."
  (interactive)
  (int<dlv>:message:boxed.xml :start "dlv:buffer-locals/show-dlvs"
                              (cons "buffer" (buffer-name))
                              (cons "path" (buffer-file-name)))
  (message "")

  (let* ((all-locals (buffer-local-variables))
         (dir-locals (alist-get 'dir-local-variables-alist
                                all-locals))
         (file-locals (alist-get 'file-local-variables-alist
                                 all-locals)))

    (int<dlv>:message:line ?─)
    (message "dir-local-variables-alist:")
    (pp dir-locals)

    (message "")
    (int<dlv>:message:line ?─)
    (message "file-local-variables-alist:")
    (pp file-locals))

  (message "")
  (int<dlv>:message:boxed.xml :end "dlv:buffer-locals/show-all"))


(defun dlv:dir-locals/show-all (filepath)
  "Show all DLVs for filepath."
  (interactive (list (read-directory-name "Path: "
                                          buffer-file-name)))
  (let (dlv.classes
        dlv.dir-cache
        dlv.class-alist
        dlv.safe-local-vars)
    (pp (dir-locals-find-file filepath)
        (lambda (char) (setq dlv.classes (cons char dlv.classes))))
    (pp dir-locals-directory-cache
        (lambda (char) (setq dlv.dir-cache (cons char dlv.dir-cache))))
    (pp dir-locals-class-alist
        (lambda (char) (setq dlv.class-alist (cons char dlv.class-alist))))
    (pp safe-local-variable-values
        (lambda (char) (setq dlv.safe-local-vars (cons char dlv.safe-local-vars))))

    (let ((char-to-str (lambda (chars)
                         (concat (nreverse chars))))
          (indent (lambda (str &optional indent)
                    (let* ((indent-amt (or indent 2))
                           (indent-fmt (format "%%%ds" indent-amt))
                           indented)
                      (dolist (line (split-string str "\n") indented)
                        (setq indented (concat indented
                                               (format indent-fmt line)
                                               "\n")))))))
      (setq dlv.classes (funcall indent (funcall char-to-str dlv.classes)))
      (setq dlv.dir-cache (funcall indent (funcall char-to-str dlv.dir-cache)))
      (setq dlv.class-alist (funcall indent (funcall char-to-str dlv.class-alist)))
      (setq dlv.safe-local-vars (funcall indent (funcall char-to-str dlv.safe-local-vars))))

    (int<dlv>:message:boxed.xml :start "dlv:dir-locals/show-all" (cons "path" filepath))
    (message "")

    (message "`enable-local-variables': %S"
             enable-local-variables)

    (int<dlv>:message:line ?─)
    (message "dir local classes:\n%s"
             dlv.classes)

    (int<dlv>:message:line ?─)
    (message "`dir-locals-directory-cache':\n%s"
             dlv.dir-cache)

    (int<dlv>:message:line ?─)
    (message "`dir-locals-class-alist':\n%s"
             dlv.class-alist)

    (int<dlv>:message:line ?─)
    (message "`safe-local-variable-values':\n%s"
             dlv.safe-local-vars)
    (int<dlv>:message:boxed.xml :end "dlv:dir-locals/show-all")))


;; TODO: move to mis?
(defmacro int<dlv>:message:stream.chars (stream)
  "Returns a lambda that stores supplied char into the STREAM variable."
  `(let ((int<dlv>:message:stream.chars:stream ,stream))
     (lambda (char) (setq int<dlv>:message:stream.chars:stream
                          (cons char int<dlv>:message:stream.chars:stream)))))


;; TODO: move to mis?
(defun int<dlv>:message:stream->str (stream)
  "Converts the character STREAM into a string destructive (uses `nreverse')."
  (concat (nreverse stream)))


;; TODO: move to mis?
(defun int<dlv>:message:indent (str &optional indent)
  "Indent each line in STR by INDENT amount (default 2).

Trims string of leading/trailing whitespace before returning."
  (let* ((indent.amt (or indent 2))
         (indent.fmt (concat "%" (number-to-string indent.amt) "s"))
         string.indented)
    (string-trim
     (dolist (line (split-string str "\n") string.indented)
       (setq indented (concat indented
                              (format indent.fmt line)
                              "\n"))))))


;; TODO: move to mis?
(defun int<dlv>:message:line (char)
  "Print an ASCII box line to the *Messages* buffer."
  (let ((width.usable 80))
    (message "\n%s\n"
             (make-string width.usable char))))


;; TODO: move to mis?
(defun int<dlv>:message:boxed.xml (start? title &rest kvp)
  "Print an ASCII boxed message to the *Messages* buffer that is XML-ish formatted.

If START? is nil or `:end', it will be an end tag.

TITLE will be the 'XML tag name'.

KVP, if not nil, should be 2-tuples (cons) of field-name and field-value strings."
  (let* ((width.total 80)
         (width.sides 2)
         (width.padding 2)
         (indent.fields 2)
         (width.usable (- 80 width.sides width.padding)) ;; 'Usable' has to account for sides of box and padding.
         (line.width.middle (make-string (- width.total width.sides) ?═))
         (format.width.title (concat "%-" (int-to-string width.usable) "s"))
         (format.width.fields (concat "%-" (int-to-string (- width.usable indent.fields)) "s")))

    ;;------------------------------
    ;; Top of box.
    ;;------------------------------
    (message "%s%s%s"
             "╔"
             line.width.middle
             "╗")

    ;;------------------------------
    ;; Box's message lines.
    ;;------------------------------
    (if (null kvp)
        ;; Just the title.
        (message "%s %s %s"
                 "║"
                 (format format.width.title
                         (concat "<"
                                 (if start? "" "/")
                                 title
                                 ">"))
                 "║")

      ;; Title on first line...
      (message "%s %s %s"
               "║"
               (format format.width.title
                       (concat "<"
                               title
                               ;; Don't close the tag.
                               " "))
               "║")

      ;; KVPs each on separate line.
      (let ((length.kvp (length kvp)))
        (dotimes (index length.kvp)
          (let ((key (car (elt kvp index)))
                (value (cdr (elt kvp index)))
                (final (= index (1- length.kvp))))
            (message "%s   %s %s"
                     "║"
                     (format format.width.fields (concat key
                                                         "=\""
                                                         value
                                                         "\""
                                                         (if final ">" " ")))
                     "║")))))

    ;;------------------------------
    ;; Bottom of box.
    ;;------------------------------
    (message "%s%s%s"
             "╚"
             line.width.middle
             "╝")
    nil))
;; (int<dlv>:message:boxed.xml "testing")
;; (int<dlv>:message:boxed.xml "testing" (cons "hello" "there"))
;; (int<dlv>:message:boxed.xml "testing" (cons "hello" "there") (cons "general" "kenobi"))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :dlv)
