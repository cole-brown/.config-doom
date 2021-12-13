;;; emacs/dlv/dlv.el -*- lexical-binding: t; -*-

;; TODO: Remove this dependency if I package this up?
(require 'dash)

(imp:require :dlv 'debug)
(imp:require :dlv 'path)
(imp:require :dlv 'class)


;;------------------------------------------------------------------------------
;; Constants
;;------------------------------------------------------------------------------

(defconst int<dlv>:const:safe.valid '(:safe t)
  "Valid constant values for `safe' in `dlv:set'.")


;;------------------------------------------------------------------------------
;; Enable / Disable DLVs
;;------------------------------------------------------------------------------

(defun dlv:enable (enable)
  "Set Emacs' `enable-local-variables' to enable/disable
Directory Local Variables.

Valid values for ENABLE are:
  - :enable, t
    + DLVs are used if safe; user is queried if some are unsafe.
  - :disable, nil
    + DLVs are never used.
  - :safe
    + Safe DLVs are used; unsafe DLVs are ignored.
  - :all
    + All DLVs are always used (not recommended).
  - <anything else>
    + Always asks user.

See `enable-local-variables' for an in-depth explanation."
  ;; Reduce our two enables and two disables down to the correct value for `enable-local-variables'.
  (cond ((memq enable '(:enable t))
         (setq enable-local-variables t))
        ((memq enable '(:disable nil))
         (setq enable-local-variables nil))

        ;; The rest are 1:1 mappings of input value->`enable-local-variables' value.
        (t
         (setq enable-local-variables enable))))


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
  "Check that each element of DLV.VARS is a valid DLV vars list."
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
  (cond ((or (null path)
             (not (stringp path)))
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
         ;; Is absolute; but needs fixed to have final slash.
         (if (not (null signal-error))
             (error (concat "%s: Directory path missing trailing slash. "
                            "Missing call to `int<dlv>:class:get'/`int<dlv>:path:expand'. "
                            "path %s")
                    caller path)
           nil))

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
  "Checks that DLV is a valid DLV structure (dirs and/or modes).

If SIGNAL-ERROR is non-nil, signals error. Else returns nil on error."
  (let ((valid t))
    (if (not (listp dlv))
        ;;------------------------------
        ;; Not even valid enough to validate? Error.
        ;;------------------------------
        (if (not (null signal-error))
            ;; Probably wasn't a cons, since the rest should've errored in their funcs.
            (error "%s: `dir.entry' is not valid! Must be a cons with valid members. %S"
                   caller
                   mode)
          (setq valid nil))

      ;;------------------------------
      ;; Validate the DLV structure.
      ;;------------------------------
      (setq valid
            (-all? (lambda (dir-or-mode.entry)
                     (or (int<dlv>:validate:dir.entry caller dir-or-mode.entry signal-error)
                         (int<dlv>:validate:mode.entry caller dir-or-mode.entry signal-error)))
                   dlv)))

    ;;------------------------------
    ;; Return the summary.
    ;;------------------------------
    valid))


;;------------------------------
;; Emacs Dir Locals
;;------------------------------

(defun int<dlv>:validate:emacs.dlv:dir.path (caller path signal-error &rest args)
  "Checks that PATH is not an emacs DLV path yet.

ARGS can be:
  - `:dir/exists' - PATH must exist on the filesystem.
  - `:dlv/exists' - PATH must exist in `dir-locals-directory-cache'.
  - `:dlv/dne'    - PATH must /not/ exist in `dir-locals-directory-cache'."
  (let ((path (expand-file-name path))
        (valid/args '(:dir/exists :dlv/exists :dlv/dne))
        (valid t))

    ;;------------------------------
    ;; Sanity Check: Must have a valid value in ARGS.
    ;;------------------------------
    (unless (and args
                 (seq-intersection valid/args args))
      ;; Ignore `signal-error' and always error - programmer fucked up.
      (error "%s: Must have a valid value in args! Valid: %S, Args: %S"
             caller valid/args args))

    ;;------------------------------
    ;; Filesystem: Dir must exist.
    ;;------------------------------
    (when (and (memq :dir/exists args)
               (not (file-directory-p path)))
      (if (not (null signal-error))
          (error "%s: `path' is not an existing directory! %S"
                 caller path)
        ;; Don't want an error, so just return false.
        (setq valid nil)))

    ;;------------------------------
    ;; Emacs DLV: Dir must (not) exist.
    ;;------------------------------
    ;; NOTE: Do not use `dir-locals-find-file' - it will give you a dir's parents' DLVs and that's a false positive (probably?).

    ;; Caller wants the DLV dir/class to already exist.
    (when (and (memq :dlv/exists args)
               (not (assoc path dir-locals-directory-cache)))
      (if (not (null signal-error))
          (error "%s: `path' is not in Emacs dir-locals! %S"
                 caller path)
        ;; Don't want an error, so just return false.
        (setq valid nil)))

    ;; Caller wants the DLV dir/class to _NOT_ exist.
    (when (and (memq :dlv/dne args)
               (assoc path dir-locals-directory-cache))
      (if (not (null signal-error))
          (error "%s: `path' is already in Emacs dir-locals! %S"
                 caller path)
        ;; Don't want an error, so just return false.
        (setq valid nil)))

    (if valid
        ;; Return something truthy. We expanded the path, so maybe that?
        path
      nil)))


;;------------------------------------------------------------------------------
;; Clean
;;------------------------------------------------------------------------------

(defun int<dlv>:clean:dlv (directory &optional signal-error)
  "Remove any invalid entries in a Directory-Local-Variable (DLV) class.

DIRECTORY should be the absolute path to the desired directory.

Had a bug in `dlv:set' that would wind up with invalid DLV structs like:
  ;; Valid.
  ((nil . (variable/00 . value/00))
   ;; Invalid - missing mode.
   (variable/01 . value/01)
   ;; Invalid - missing mode.
   (variable/00 . value/00))

This will set that DLV struct to:
  ((nil . (variable/00 . value/00)))"
  (let ((func.name "int<dlv>:clean:dlv")
        (valid t))
    (int<dlv>:debug func.name
                    (concat "[INPUTS]:\n"
                            "  directory: %S\n"
                            "  error?:    %S")
                    directory
                    signal-error)

    ;;------------------------------
    ;; Validate inputs.
    ;;------------------------------
    (if (not (int<dlv>:validate:dir.path func.name directory signal-error))
        (if (not (null signal-error))
            (error "%s: DIRECTORY must be valid! Got: %S"
                   func.name directory)
          (setq valid nil))

      ;;------------------------------
      ;; Get DLV dirs/classes list.
      ;;------------------------------
      (let ((dirs-and-classes (int<dlv>:class:get directory)))
        (int<dlv>:debug func.name
                        (concat "[GET] Dirs & Classes:\n"
                                "%s")
                        (pp-to-string dirs-and-classes))

        ;;------------------------------
        ;; Get each existing DLV struct to clean.
        ;;------------------------------
        (dolist (dir-and-class dirs-and-classes)
          (let* ((dlv.directory (car dir-and-class))
                 (dlv.class (cdr dir-and-class))
                 (existing/dlv.struct (dir-locals-get-class-variables dlv.class))
                 cleaned/dlv.struct)

            ;; We got the dirs/classes from emacs, so we are expecting to have a valid dir path.
            (if (not (int<dlv>:validate:emacs.dlv:dir.path func.name dlv.directory signal-error :dir/exists :dlv/exists))
                (if (not (null signal-error))
                    (error "%s: Cannot clean DLVs for directory; existing Emacs DLV was not found for it. directory: '%s'"
                           func.name
                           dlv.directory)
                  (setq valid nil))

              ;; Is there anything to clean? We got the dirs/classes from Emacs so there should be.
              ;; So... error if there isn't one.
              (if (null existing/dlv.struct)
                  (if (not (null signal-error))
                      (error (concat "%s: Cannot clean DLVs for directory; "
                                     "an existing Emacs DLV class was not found for it.\n"
                                     "  expected class symbol: %S\n"
                                     "  directory:             %s\n"
                                     "  existing/dlv.struct:   %S"
                                     func.name
                                     dlv.class
                                     dlv.directory
                                     existing/dlv.struct))
                    (setq valid nil))

                ;;------------------------------
                ;; Passed the error checking; clean the DLV.
                ;;------------------------------
                (int<dlv>:debug func.name
                                (concat "[CLEANING] Clean DLV class `%S'...\n"
                                        "  DLV dir:    %s\n"
                                        "  DLV class:  %S\n"
                                        "  DLV struct: %S")
                                dlv.class
                                dlv.directory
                                dlv.class
                                existing/dlv.struct)

                ;;------------------------------
                ;; Clean each DLV mode.
                ;;------------------------------
                (dolist (kvp existing/dlv.struct)
                  ;; Is this a valid dlv mode->vars (or dir->(mode->vars, ...)) tuple?
                  (if (or (int<dlv>:validate:dir.entry func.name kvp nil)
                          (int<dlv>:validate:mode.entry func.name kvp nil))
                      ;; Valid, so we keep it. Push to `cleaned/dlv.struct'.
                      (progn
                        (int<dlv>:debug func.name
                                        (concat "[CLEAN:keep] Valid dir or class entry:\n"
                                                "%s")
                                        (pp-to-string kvp))
                        (push kvp cleaned/dlv.struct))

                    ;; Invalid, so do not keep it. Debug message it and continue.
                    ;; It won't be in `cleaned/dlv.struct' so it will get lost when we set.
                    (int<dlv>:debug func.name
                                    (concat "[CLEAN:DROP] Invalid dir or class entry:\n"
                                            "%s")
                                    (pp-to-string kvp))))

                ;;------------------------------
                ;; Set the cleaned DLV back.
                ;;------------------------------
                ;; Did we update `cleaned/dlv.struct' in the cond?
                (if (or (null cleaned/dlv.struct)
                        (equal existing/dlv.struct cleaned/dlv.struct))
                    (progn
                      (int<dlv>:debug func.name
                                      "[CLEAN:no-op] Nothing changed for DLV class: %S"
                                      dlv.class)
                      ;; Return something to indicate this state.
                      (setq valid :no-op))

                  ;; Set it to approximately the order it used to be.
                  (setq cleaned/dlv.struct (nreverse cleaned/dlv.struct))
                  (int<dlv>:directory-class.update func.name
                                                   dlv.class
                                                   cleaned/dlv.struct)
                  (int<dlv>:debug func.name
                                  (concat "[CLEAN:UPDATE] Cleaned invalids out of DLV class:\n"
                                          "  class:        %S\n"
                                          "  clean struct:\n"
                                          "%s")
                                  dlv.class
                                  (pp-to-string cleaned/dlv.struct))
                  ;; Return something to indicate this state.
                  (setq valid :cleaned))))))))

    ;; Return valid/invalid state.
    valid))


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


(defun dlv:var:safe/value? (symbol value)
  "Returns non-nil if SYMBOL is considered safe for VALUE.

SYMBOL is safe if either:
  - It has a predicate in its `safe-local-variable' property,
    AND that predicate returns non-nil for VALUE.
  - It has an entry in the `safe-local-variable-values' alist that matches VALUE.

The validness of VALUE is checked via `safe-local-variable-p'."
  (safe-local-variable-p symbol value))


(defun dlv:var:safe/predicate? (symbol)
  "Returns SYMBOL's `safe-local-variable' property."
  (get symbol 'safe-local-variable))


(defun dlv:var:risky? (symbol &optional only-prop)
  "Returns non-nil if the SYMBOL considered risky for DLVs.

If ONLY-PROP is non-nil, only checks the SYMBOL's `risky-local-variable' property.
Otherwise does the full check via `risky-local-variable-p'."
  (if only-prop
      (get symbol 'risky-local-variable)
    (risky-local-variable-p symbol)))


(defun int<dlv>:var:risky.remove (caller symbol remove-type info-func fail-func)
  "Attempts to remove riskiness of SYMBOL.

If it can, it does so by deleting the `risky-local-variable' property.
If it cannot, it will call FAIL-FUNC (use `error', `message', etc) with info.

If REMOVE-TYPE is `:quiet', just delete its risky property quietly.
Otherwise, calls INFO-FUNC with a warning/info message."
  ;; Ignore non-risky vars.
  (when (risky-local-variable-p symbol)
    ;; What kind of risky is it? The kind we can undo?
    (if-let ((prop.risky (dlv:var:risky? symbol :only-prop)))
        ;; Ok - can de-risk this. Should we complain about it?
        (progn
          (unless (eq remove-type :quiet)
            (funcall info-func
                     "%s: '%S': Deleting `risky-local-variable' property (current value: %S)."
                     caller
                     symbol
                     prop.risky))
          ;; Delete its risky property.
          (put symbol 'risky-local-variable nil))

      ;; Cannot de-risk it. Give return of `risky-local-variable-p' for maybe some info?
      (funcall fail-func
               (concat "%s: '%S': "
                       "Cannot undo the symbol's riskiness - "
                       "it's not considered risky via the `risky-local-variable' property. "
                       "`(risky-local-variable-p %S)' -> %S")
               caller
               symbol
               symbol
               (risky-local-variable-p symbol)))))


(defun dlv:var:safe.predicate (symbol predicate &optional remove-risky)
  "Mark SYMBOL as safe using PREDICATE function for Directory Local Variables.

If REMOVE-RISKY is non-nil, will set `risky-local-variable' property to nil.

If REMOVE-RISKY is nil and the SYMBOL is considered risky, this will signal
an error.

When de-risking SYMBOL, if REMOVE-RISKY is `:quiet', just delete its
risky property quietly. Otherwise, `message' a warning.

NOTE: if a symbol is considered risky for some reason other than the
`risky-local-variable' property, REMOVE-RISKY will not work and will signal an error."
  (let ((func.name "dlv:var:safe.predicate"))
    ;; Check some errors first.
    (cond ((not (functionp predicate))
           (error "%s: Cannot mark SYMBOL (%S) as safe; PREDICATE is not a function? %S"
                  func.name
                  symbol
                  predicate))
          ((and (risky-local-variable-p symbol)
                (null remove-risky))
           (error ": Cannot mark SYMBOL (%S) as safe; It is considered risky: %S"
                  func.name
                  symbol
                  (risky-local-variable-p symbol)))
          ;; Passed error checks; do it.
          (t
           ;; Force to not risky?
           (when remove-risky
             ;; `message' if not quiet, `error' if cannot remove the riskiness.
             (int<dlv>:var:risky.remove func.name
                                        symbol
                                        remove-risky
                                        #'message
                                        #'error))

           ;; Set the safe predicate.
           (int<dlv>:vars:safe "dlv:var:safe.function" symbol predicate)))))


(defun dlv:var:safe.value (symbol value &optional remove-risky)
  "Add SYMBOL and VALUE as a known-safe combination for
Directory Local Variables."
  (let ((func.name "dlv:var:safe.value"))
    ;; Force to not risky?
    (when remove-risky
      ;; `message' if not quiet, `error' if cannot remove the riskiness.
      (int<dlv>:var:risky.remove func.name
                                 symbol
                                 remove-risky
                                 #'message
                                 #'error))

    ;; Add the key-value pair to the safe alist.
    (push (cons symbol value) safe-local-variable-values)))


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

Returns the updated alist.
NOTE: Caller should save return value back to their alist variable!"
  (let ((func.name "int<dlv>:vars:pair.set"))
    (int<dlv>:debug func.name
                    (concat "Set pair into DLV vars:\n"
                            "  pair:       %S\n"
                            "    -> var:   %S\n"
                            "    -> value: %S\n"
                            "  vars:       %S")
                    pair
                    (if (listp pair) (car pair) "<invalid?>")
                    (if (listp pair) (cdr pair) "<invalid?>")
                    dlv.vars)

    (if (not (int<dlv>:validate:var.pair func.name pair :error))
        ;; Should have already errored, but just in case:
        (error "%s: `pair' failed validation! %S"
               func.name pair)

      ;; Valid - set/update the var in the alist.
      (if (null (assoc (car pair) dlv.vars)) ;; empty alist?
          ;; Create alist w/ this pair.
          (progn
            (push pair dlv.vars)
            (int<dlv>:debug func.name
                            (concat "Create `dlv.vars':\n"
                                    "  pair: %S\n"
                                    "  vars: %S")
                            pair
                            dlv.vars))

        ;; Add-to/update-in alist.
        (setf (alist-get (car pair) dlv.vars)
              (cdr pair))
        (int<dlv>:debug func.name
                        (concat "Add-to/update `dlv.vars':\n"
                                "  pair: %S\n"
                                "  vars: %S")
                        pair
                        dlv.vars))

      ;; Return the updated alist.
      (int<dlv>:debug func.name
                      (concat "Returning `dlv.vars':\n"
                              "%s")
                      (pp-to-string dlv.vars))
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

NOTE: May or may not change the input list!

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


(defun int<dlv>:exists? (directory)
  "Does the dir-locals class exist for this DIRECTORY?

Returns a list of paths (which are DIRECTORY) that have a DLV class already."
  (let ((dirs-and-classes (int<dlv>:class:get directory))
        existing)
    (dolist (dir-and-class dirs-and-classes)
      (when (dir-locals-get-class-variables (cdr dir-and-class))
        (push (car dir-and-class) existing)))

    existing))


;;------------------------------------------------------------------------------
;; DLV API
;;------------------------------------------------------------------------------

(defun int<dlv>:directory-class.create (caller dlv.class dlv.directory dlv.struct)
  "Set DLV.STRUCT structure as CLASS for DIRECTORY.

Does no error checking/validation."
  ;; Set the class of dlv variables and apply it to the directory.
  (int<dlv>:debug caller "Creating class variables `%S': %s" dlv.class dlv.struct)
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
  (int<dlv>:debug caller "Updating class variables `%S': %s" dlv.class dlv.struct)
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

Returns a list of DLV class symbol(s)."
  (let ((func.name "dlv:create"))
    (int<dlv>:debug func.name
                    (concat "Inputs:\n"
                            "  directory: %S\n"
                            "  mode:      %S\n"
                            "  tuples:     %S")
                    directory
                    mode
                    tuples)

    ;;------------------------------
    ;; Validate inputs.
    ;;------------------------------
    ;; Some inputs will be validate when building the DLV structure, so just validate the rest.

    (unless (int<dlv>:validate:dir.path func.name directory :error)
      (error "%s: DIRECTORY must be valid! Got: %S"
             func.name directory))

    (let ((dirs-and-classes (int<dlv>:class:get directory)))
      (int<dlv>:debug func.name
                      (concat "Dirs & Classes:\n"
                              "  %S")
                      dirs-and-classes)

      ;; Validate dlv class symbol and directory for each created.
      ;; Can have more than one for e.g. paths in $HOME.
      (dolist (dir-and-class dirs-and-classes)
        (unless (int<dlv>:validate:class.symbol func.name (cdr dir-and-class) :error)
          (error "%s: `dlv.class' must be valid! Got: %S for directory '%s'"
                 func.name (cdr dir-and-class) (car dir-and-class)))
        ;; Creating, so don't allow if one already exists for the dir.
        (unless (int<dlv>:validate:emacs.dlv:dir.path func.name (car dir-and-class) :error :dir/exists :dlv/dne)
          (error "%s: Cannot create entry for directory; Emacs DLV already exists for it. DIRECTORY: '%s'"
                 func.name
                 (car dir-and-class))))

      ;; MODE, TUPLES validated in `let*', below.

      ;;------------------------------
      ;; Make the DLV(s).
      ;;------------------------------

      (let (created/dlv.classes)
        (dolist (dir-and-class dirs-and-classes)
          ;; Create the struct for the DLV.
          (let* ((dlv.directory (car dir-and-class))
                 (dlv.class (cdr dir-and-class))
                 (dlv.vars (apply #'int<dlv>:vars:create tuples))
                 (dlv.mode (int<dlv>:mode:entry.create mode dlv.vars))
                 (dlv.struct (int<dlv>:struct:create dlv.mode)))
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
            (push (int<dlv>:directory-class.create func.name dlv.class dlv.directory dlv.struct) created/dlv.classes)))
        created/dlv.classes))))


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
      for Directory Local Value use."
  (let ((func.name "dlv:update"))
    (int<dlv>:debug func.name
                    (concat "[INPUTS]:\n"
                            "  directory: %S\n"
                            "  mode:      %S\n"
                            "  tuples:    %S")
                    directory
                    mode
                    tuples)

    ;;------------------------------
    ;; Validate inputs.
    ;;------------------------------
    ;; Some inputs will be validate when building the DLV structure, so just validate the rest.

    (unless (int<dlv>:validate:dir.path func.name directory :error)
      (error "%s: DIRECTORY must be valid! Got: %S"
             func.name directory))

    (let ((dirs-and-classes (int<dlv>:class:get directory)))
      (int<dlv>:debug func.name
                      (concat "[GET] Dirs & Classes:\n"
                              "  %S")
                      dirs-and-classes)

      ;;---
      ;; Class should already exist.
      ;;---
      (int<dlv>:debug func.name
                      (concat "[VERIFY] DLV dir/class must pre-exist:\n"
                              "  dir:                %S\n"
                              "  dlv dirs & classes: %S")
                      directory
                      dirs-and-classes)

      ;; Before we get and update them, clean up the existing DLVs.
      (let ((cleaned (int<dlv>:clean:dlv directory :error)))
        (int<dlv>:debug func.name
                        "[CLEAN] DLV dir/class clean returned: %S"
                        cleaned))

      ;; Might as well run through path validation... And don't let the validation function
      ;; error, since we want this to 'fail' (return 'already a class for that dir').
      (dolist (dir-and-class dirs-and-classes)
        (let* ((dir (car dir-and-class))
               (class (cdr dir-and-class))
               (existing/dlv.struct (dir-locals-get-class-variables class)))
          (unless (int<dlv>:validate:emacs.dlv:dir.path func.name dir :error :dir/exists :dlv/exists)
            (error "%s: Cannot update entry for directory; directory failed validation. directory: '%s'"
                   func.name
                   dir))

          ;; Updating, so don't allow if one /does not/ exists for the dir.
          (if existing/dlv.struct
              ;; Allowed - found existing.
              (int<dlv>:debug func.name
                              (concat "[VERIFY:OK] DLV dir/class exists!\n"
                                      "  dir:      %S\n"
                                      "  class:    %S\n"
                                      "  existing: %S")
                              dir
                              class
                              existing/dlv.struct)

            ;; Not found; not allowed - error out.
            (error (concat "%s: Cannot update entry for directory; "
                           "an existing Emacs DLV class was not found for it. "
                           "expected class symbol: %S, "
                           "directory: '%s', "
                           "existing/dlv.struct: %S"
                           func.name
                           class
                           dir
                           existing/dlv.struct)))))

      ;; MODE, TUPLES validated in `let*', below.

      ;;------------------------------
      ;; Update the DLV.
      ;;------------------------------

      (int<dlv>:debug func.name
                      "[UPDATE] Apply updates to DLV classes...")

      (let (updated/dlv.classes)
        (dolist (dir-and-class dirs-and-classes)
          ;; Break the existing DLV struct down, so that we can update the new pieces.
          ;; Also create our DLV vars.
          (let* ((dlv.directory (car dir-and-class))
                 (dlv.class (cdr dir-and-class))
                 (existing/dlv.struct (dir-locals-get-class-variables dlv.class))
                 (existing/dlv.vars (int<dlv>:mode:vars.get mode existing/dlv.struct))
                 (dlv.vars (apply #'int<dlv>:vars:create tuples))
                 ;; This is the DLV cons of (<mode> . <vars/alist>).
                 dlv.mode)
            (int<dlv>:debug func.name
                            (concat "[UPDATE] Apply update to:\n"
                                    "  DLV dir:    %S\n"
                                    "  DLV class:  %S\n"
                                    "  DLV struct: %S\n"
                                    "  DLV vars:   \n"
                                    "    Existing: %S\n"
                                    "    New:      %S")
                            dlv.directory
                            dlv.class
                            existing/dlv.struct
                            existing/dlv.vars
                            dlv.vars)

            ;;------------------------------
            ;; Add/Update DLV mode vars.
            ;;------------------------------
            (if existing/dlv.vars
                ;;---
                ;; Add/update vars in existing mode.
                ;;---
                (progn
                  (int<dlv>:debug func.name
                                  (concat "[UPDATE] Add/update vars to existing mode vars:\n"
                                          "  DLV dir:   %S\n"
                                          "  DLV class: %S\n"
                                          "  mode:      %S\n"
                                          "  DLV vars:   \n"
                                          "    Existing: %S\n"
                                          "    New:      %S")
                                  dlv.directory
                                  dlv.class
                                  mode
                                  existing/dlv.vars
                                  dlv.vars)

                  ;; Update each var in inputs.
                  (dolist (kvp dlv.vars)
                    (setq existing/dlv.vars
                          (int<dlv>:vars:pair.set kvp existing/dlv.vars))
                    (int<dlv>:debug func.name
                                    (concat "[UPDATE] Updated `existing/dlv.vars':\n"
                                            "  mode:         %S\n"
                                            "  var:          %S\n"
                                            "  updated vars: %S")
                                    mode
                                    kvp
                                    existing/dlv.vars))

                  ;; Set mode's updated vars.
                  (setq dlv.mode (int<dlv>:mode:entry.create mode existing/dlv.vars))
                  (int<dlv>:debug func.name
                                  (concat "[UPDATE] Updated `dlv.mode':\n"
                                          "  dlv.mode: %S")
                                  dlv.mode))

              ;;---
              ;; Create mode for vars.
              ;;---
              ;; No existing vars for the mode, so... Create the mode.
              (int<dlv>:debug func.name
                              (concat "[UPDATE] Create new mode:\n"
                                      "  dir:       %S\n"
                                      "  mode:      %S"
                                      "  DLV class: %S\n"
                                      "  DLV mode:  %S")
                              dlv.directory
                              mode
                              dlv.class
                              dlv.mode)
              (setq dlv.mode (int<dlv>:mode:entry.create mode dlv.vars))
              (int<dlv>:debug func.name
                              (concat "[UPDATE] Created `dlv.mode':\n"
                                      "  mode:     %S\n"
                                      "  dlv.mode: %S")
                              mode
                              dlv.mode))

            ;;------------------------------
            ;; Finalize
            ;;------------------------------
            ;; Set the new/updated mode entry into the dlv struct.
            (int<dlv>:debug func.name
                            (concat "[UPDATE] Setting new `dlv.mode' in existing DLV:\n"
                                    "  mode: %S\n"
                                    "  DLV mode, UPDATED:\n"
                                    "%s"
                                    "  DLV struct, existing:\n"
                                    "%s")
                            mode
                            (pp-to-string dlv.mode)
                            (pp-to-string existing/dlv.struct))
            ;; NOTE: `int<dlv>:mode:set' may or may not update `existing/dlv.struct', so:
            ;;   a) Always set its output back to `existing/dlv.struct'.
            ;;   b) No point in setting it to e.g. `updated/dlv.struct' since `existing/dlv.struct' may be changed too.
            (setq existing/dlv.struct (int<dlv>:mode:set dlv.mode existing/dlv.struct))
            (int<dlv>:debug func.name
                            (concat "[UPDATE] Set new `dlv.mode'.\n"
                                    "  mode: %S\n"
                                    "  DLV struct (UPDATED):\n"
                                    "%s")
                            mode
                            (pp-to-string existing/dlv.struct))

            ;; And now we can replace the DLV struct in Emacs.
            (let ((updated/dlv.class (int<dlv>:directory-class.update func.name
                                                                      dlv.class
                                                                      existing/dlv.struct)))
              (push updated/dlv.class updated/dlv.classes)
              (int<dlv>:debug func.name
                              (concat "[UPDATE] Updated DLV classes for directory:\n"
                                      "  dir:   %S\n"
                                      "  class: %S\n"
                                      "  dlv.class (ours; updated):\n"
                                      "%s"
                                      "  dlv.class (emacs; fresh get):\n"
                                      "%s")
                              directory
                              dlv.class
                              (pp-to-string updated/dlv.class)
                              (pp-to-string (dir-locals-get-class-variables dlv.class))))))

        ;;------------------------------
        ;; Return
        ;;------------------------------
        (int<dlv>:debug func.name
                        (concat "[UPDATE] Updated:\n"
                                "  dir: %S\n"
                                "  class->vars:\n"
                                "%s")
                        directory
                        (pp-to-string updated/dlv.classes))

        updated/dlv.classes))))


(defun dlv:set (directory mode &rest tuples)
  "Create or update a Directory-Local-Variable (DLV) class.

DIRECTORY should be the absolute path to the desired directory.

MODE should be the mode the DLV applies to, or `nil' for global mode.

Each TUPLES parameter should be a list of '(symbol value safe) tuples.
  - symbol - the symbol to set as a DLV
  - value  - the symbol's directory local value
  - safe   - a predicate function or `t'/`:safe'
    + If a function, store that predicate in the symbol's `safe-local-variable'
      slot for Emacs to use.
    + If `t' or `:safe', do nothing; symbol is assumed to be already marked safe
      for Directory Local Value use."
  (if (int<dlv>:exists? directory)
      (apply #'dlv:update directory mode tuples)
    (apply #'dlv:create directory mode tuples)))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :dlv 'dlv)
