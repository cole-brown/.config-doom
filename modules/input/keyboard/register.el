;;; input/keyboard/register.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                       Register to be The Layout.                       ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                           There can be only one.                           ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defvar input//kl:layout:keybinds nil
  "The keybinds for the active layout.

Saved in `input:keyboard/layout:set' during module config; set/activated in
`input:keyboard/layout:activate' during module finalization.

This is an alist with 3 expected entries:
  :common - Any keybinds that exist in both evil-mode and standard Emacs.
  :emacs  - Any Emacs-only keybinds (non-evil-mode).
  :evil   - Any Evil-only keybinds.

Each alist key's value should be a list of args for
`input:keyboard/layout:map!'.")
;; (pp-macroexpand-expression input//kl:layout:keybinds)


(defvar input//kl:layout:unbinds nil
  "The unbindings for the active layout.

Saved in `input:keyboard/layout:set' during module config; set/activated in
`input:keyboard/layout:activate' during module finalization.

This is an alist with 3 expected entries:
  :common - Any keybinds that should just be unset.
  :emacs  - Any Emacs-only unbinds.
  :evil   - Any Evil-only unbinds.

Each alist key's value should be a list of args for
`input:keyboard/layout:map!'.")


(defconst input//kl:layout:types '((:common . "common")
                                   (:emacs  . "emacs")
                                   (:evil   . "evil"))
  "Allowed types for a few function args, alist keys.

Types are:
  :common - Any keybinds that exist in both evil-mode and standard Emacs.
  :emacs  - Any Emacs-only keybinds (non-evil-mode).
  :evil   - Any Evil-only keybinds.")
;; input//kl:layout:types
;; (makunbound 'input//kl:layout:types)


(defvar input//kl:layout:registering nil
  "The state of registration/initialization.

Valid States (see `input//kl:layout:registering/states'
and `input//kl:layout:registering/valid'):
  nil - Nothing has happened yet.
  :init - Initialization happened.
  :config - Configuration happened.
  :active - Activation/finalization happened w/ valid keybinds.
  :inactive - Activation/finalization happened w/o valid keybinds.
  :temp - Someone called `input:keyboard/layout:temp'
  :apply - Someone called `input:keyboard/layout:apply' and it's about to let init do its thing.")


(defconst input//kl:layout:registering/states
  '(nil
    :init
    :config
    :active
    :inactive
    :temp
    :apply)
  "All valid values for `input//kl:layout:registering'.")


(defconst input//kl:layout:registering/valid
  ;;    '(state     . (list of valid states to transition from))
  (list '(nil       . (nil :temp))
        '(:init     . (nil :temp :apply))
        '(:config   . (:init :temp))
        '(:active   . (:config :temp))
        '(:inactive . (nil :init :config :temp))
        '(:temp     . (:active :inactive :temp))

        ;;---
        ;; Valid to enter from (almost) any state:
        ;;---
        (cons :apply  input//kl:layout:registering/states))
  "Alist of all valid values for moving `input//kl:layout:registering'
to a certain state.")


(defconst input//kl:bind/unbind
  '((:bind   . (:set :bind))
    (:unbind . (:unset :unbind))
    (:full   . (:full)))
  "Bind/unbind keywords alist. Canonical keyword -> alias keywords list.

`:full' allows for unbinding and then binding (used during normal init/config).

`:bind' and `:unbind' are more used in testing.")


;;------------------------------------------------------------------------------
;; Functions: Bind / Unbind
;;------------------------------------------------------------------------------

(defun input//kl:bind/unbind:valid? (keyword)
  "Returns canonical keyword for KEYWORD if it is a valid bind/unbind keyword.

Returns nil if not valid."
  (let (canon)
    ;; Search for the canonical name.
    (dolist (entry input//kl:bind/unbind)
      ;; Keyword in valid aliases?
      (when (memq keyword (cdr entry))
        ;; Save canonical keyword.
        (setq canon (car entry))))

    ;; No valid found - error out.
    (unless canon
      (let (valids)
        (dolist (entry input//kl:bind/unbind)
          (dolist (alias (cdr entry))
            (push alias valids)))
        (error (input//kl:error/format "input//kl:bind/unbind"
                                       "`keyword' is not a valid bind/unbind keyword. "
                                       "Must be one of: %S; "
                                       "got: %S")
               valids
               keyword)))

    ;; Have valid canonical keyword; return it.
    canon))
;; (input//kl:bind/unbind:valid? :bind)
;; (input//kl:bind/unbind:valid? :set)
;; (input//kl:bind/unbind:valid? :jeff)
;; (input//kl:bind/unbind:valid? :full)


;;------------------------------------------------------------------------------
;; Functions: Type Validity, etc.
;;------------------------------------------------------------------------------

(defun input//kl:layout:valid/type? (type)
  "Returns non-nil if TYPE is a valid type.

See `input//kl:layout:types for the alist of valid types."
  (input//kl:alist/entry type input//kl:layout:types))
;; (input//kl:layout:valid/type? :emacs)


(defun input//kl:layout:type->string (type)
  "Returns the string for TYPE keyword."
  ;; We have `input//kl:layout:valid/type?' returning the alist entry.
  (cdr (input//kl:layout:valid/type? type)))
;; (input//kl:layout:type->string :emacs)


(defun input//kl:layout:registering/get-valids (desired)
  "Get the list of valid values `input//kl:layout:registering' can be for
entering DESIRED state."
  (alist-get desired input//kl:layout:registering/valid))


(defun input//kl:layout:registering/set-if-valid? (to &optional no-set no-error)
  "Returns non-nil if transition of `input//kl:layout:registering' to new TO
state is valid.

If NO-SET is non-nil, skips setting `input//kl:layout:registering'.

If NO-ERROR is non-nil, will return nil instead of signaling an error."
  ;; Check for errors.
  (cond ((not (memq input//kl:layout:registering
                    input//kl:layout:registering/states))
         (input//kl:debug
             "input//kl:layout:registering/set-if-valid?"
             '(:registering)
           "From (%S) is not a valid state: %S"
           input//kl:layout:registering
           input//kl:layout:registering/states)
         nil)
        ((not (memq to input//kl:layout:registering/states))
         (input//kl:debug
             "input//kl:layout:registering/set-if-valid?"
             '(:registering)
           "To (%S) is not a valid state: %S"
           to
           input//kl:layout:registering/states)
         nil)

        ;;------------------------------
        ;; Valid Cases:
        ;;------------------------------
        ;; Set to itself: ok.
        ((eq to input//kl:layout:registering)
         t)
        ;; Check for valid transition, set if found (and not `no-set').
        (t
         (let ((valid/froms (input//kl:layout:registering/get-valids to)))
           (if (not (memq input//kl:layout:registering valid/froms))
               ;; Invalid transition - error or return nil.
               (if no-error
                   nil
                 (error (input//kl:error/format "input//kl:layout:registering/set-if-valid?"
                                                "`input//kl:layout:registering' cannot transition from `%S' to `%S' state. "
                                                "Must be one of: %S")
                        input//kl:layout:registering
                        to
                        valid/froms))
             ;; Valid. Check if we want to also set it, return non-nil.
             (unless no-set
               (setq input//kl:layout:registering to))
             t)))))
;; (input//kl:layout:registering/set-if-valid? :temp)
;; input//kl:layout:registering
;; (input//kl:layout:registering/set-if-valid? :inactive t)
;; input//kl:layout:registering
;; (input//kl:layout:registering/set-if-valid? :inactive)
;; input//kl:layout:registering
;; (input//kl:layout:registering/set-if-valid? :active)
;; (input//kl:layout:registering/set-if-valid? :active nil t)


(defun input//kl:states->keyword (states)
  "Convert a list of evil STATES symbols into a keyword for `map!'.

The inverse of `doom--map-keyword-to-states'.

For example, (list 'normal 'visual 'insert) will map to `:nvi'. See
`doom-evil-state-alist' to customize this."
  (let (keyword/char-list)
    ;; Convert to list of chararcters...
    (dolist (state states)
      (if-let ((state/char (nth 0 (rassoc (doom-unquote state) doom-evil-state-alist))))
          (push state/char keyword/char-list)
        (error "input//kl:states->keyword: Invalid state: %S" state)))
    ;; And now convert our list of chars into a keyword.
    (if keyword/char-list
        (intern (apply #'string ?: (nreverse keyword/char-list)))
      (error (concat "input//kl:states->keyword: No result from states? "
                     "states: %S -> keyword characters: %S")
             states keyword/char-list))))
;; (input//kl:states->keyword '(normal visual))


;;------------------------------------------------------------------------------
;; Functions: Initialization
;;------------------------------------------------------------------------------

(defun input:keyboard/layout:bind (layout type keybind-map)
  "Saves TYPE's KEYBIND-MAP for final configuration in
`input:keyboard/layout:activate'.

TYPE should be one of:
  :common - Any keybinds that exist in both evil-mode and standard Emacs.
  :emacs  - Any Emacs-only keybinds (non-evil-mode).
  :evil   - Any Evil-only keybinds.

If called twice with the same TYPE, the later KEYBIND-MAP will overwrite the
earlier."
  (declare (indent 2))
  (when (not (input//kl:valid/layout? layout))
    (error (input//kl:error/format "input:keyboard/layout:set"
                                   "`layout' must be a keyword. "
                                   "Got: %S")
           layout))

  (when (not (input//kl:layout:valid/type? type))
    (error (input//kl:error/format "input:keyboard/layout:set"
                                   "Type '%S' is not a valid type. "
                                   "Must be one of: %S")
           type input//kl:layout:types))

  ;; Set to `:init' state unless we're in some finalized state. If we're in a finalized state,
  ;; just let the keymap be updated for possibly an `input:keyboard/layout:apply' or something.
  ;; TODO: move finalized states to a var.
  (unless (memq input//kl:layout:registering '(:active :inactive :temp))
    ;; This will error out for us.
    (input//kl:layout:registering/set-if-valid? :init))

  ;; Ok - errors checked; set it.
  (setq input//kl:layout/active layout)
  (input//kl:alist/update type keybind-map input//kl:layout:keybinds t))
;; (pp-macroexpand-expression input//kl:layout:keybinds)


(defun input:keyboard/layout:unbind (layout type unbind-map)
  "Saves TYPE's UNBIND-MAP for final configuration in
`input:keyboard/layout:activate'.

TYPE should be one of:
  :common - Any keybinds that exist in both evil-mode and standard Emacs.
  :emacs  - Any Emacs-only keybinds (non-evil-mode).
  :evil   - Any Evil-only keybinds.

If called twice with the same TYPE, the later UNBIND-MAP will overwrite the
earlier.

Unbindings are applied before bindings."
  (declare (indent 2))
  (when (not (input//kl:valid/layout? layout))
    (error (input//kl:error/format "input:keyboard/layout:unset"
                                   "`layout' must be a keyword. "
                                   "Got: %S")
           layout))

  (when (not (input//kl:layout:valid/type? type))
    (error (input//kl:error/format "input:keyboard/layout:unset"
                                   "Type '%S' is not a valid type. "
                                   "Must be one of: %S")
           type input//kl:layout:types))

  ;; Set to `:init' state unless we're in some finalized state. If we're in a finalized state,
  ;; just let the keymap be updated for possibly an `input:keyboard/layout:apply' or something.
  ;; TODO: move finalized states to a var.
  (unless (memq input//kl:layout:registering '(:active :inactive :temp))
    ;; This will error out for us.
    (input//kl:layout:registering/set-if-valid? :init))

  ;; Ok - errors checked; set it.
  (setq input//kl:layout/active layout)
  (input//kl:alist/update type unbind-map input//kl:layout:unbinds t))
;; (pp-macroexpand-expression input//kl:layout:unbinds)
;; (pp-macroexpand-expression input//kl:layout:keybinds)


;;------------------------------------------------------------------------------
;; Functions: Configuration
;;------------------------------------------------------------------------------

(defun input:keyboard/layout:config (bind/unbind layout)
  "Verifies that LAYOUT is still valid and is ready for finalization.

BIND/UNBIND should be a valid keyword in `input//kl:bind/unbind'.

LAYOUT should be a valid keyboard layout keyword."
  ;;---
  ;; Can use finalization's check here w/ known-good type.
  ;;---
  (input//kl:activate/validate "input:keyboard/layout:config"
                               bind/unbind
                               :common
                               :config)

  ;;---
  ;; Also verify the `layout'.
  ;;---
  (unless (input//kl:valid/layout? layout :active)
    (error (input//kl:error/format "input:keyboard/layout:set"
                                   "`layout' must be a keyword. "
                                   "Got: %S")
           layout))

  ;; This will error out for us.
  (input//kl:layout:registering/set-if-valid? :config)

  ;;------------------------------
  ;; Configuration
  ;;------------------------------
  ;; Nothing to do, currently.
  ;;
  ;; Only steps that need to happen after `input:keyboard/layout:set' is the
  ;; `input:keyboard/layout:activate', which happens in Finalization.
  ;;
  ;; NOTE: If we get something to do: obey `bind/unbind'!
  )


;;------------------------------------------------------------------------------
;; Functions: Finalization
;;------------------------------------------------------------------------------

;; Also used in config step, currently, but could make that have its own checks
;; if this needs to change to be specific to finalization.
(defun input//kl:activate/validate (func bind/unbind type registering)
  "Checks that things are valid for `input:keyboard/layout:activate'.

1. There must be an active layout.
2. Some keybinds must be set/saved.
3. BIND/UNBIND must be valid
4. TYPE must be valid.
5. `input//kl:layout:registering' must be able to transition to REGISTERING.

FUNC should be the function name of the caller.

BIND/UNBIND should be a valid keyword in `input//kl:bind/unbind'.

TYPE should be one of the keywords from `input//kl:layout:types'.

REGISTERING should be a registering state (see `input//kl:layout:registering/states')."
  (let ((canon:bind/unbind (input//kl:bind/unbind:valid? bind/unbind)))
    (cond ((not (input//kl:bind/unbind:valid? bind/unbind))
           ;; Should have already signaled an error if invalid, but to be extra cautious:
           (error (input//kl:error/format func
                                          "Invalid bind/unbind keyword `%S'.")
                  bind/unbind))

          ((not (input//kl:layout:registering/set-if-valid? registering 'no-set))
           ;; set-if-valid? will signal error, so no need to do it again.
           (error (input//kl:error/format func
                                          "Cannot transition registering state %S -> %S.")
                  input//kl:layout:registering
                  registering))

          ((null input//kl:layout/active)
           (error (input//kl:error/format func
                                          "No active layout set; cannot configure keyboard layout! "
                                          "desired: '%S', "
                                          "active:  '%S'")
                  input//kl:layout/desired
                  input//kl:layout/active))

          ;; If we're binding, we need keys to bind.
          ((and (memq canon:bind/unbind '(:bind :full))
                (null input//kl:layout:keybinds))
           (error (input//kl:error/format func
                                          "Active layout has not set its keybinds; "
                                          "cannot configure keyboard layout! "
                                          "Expected %S to have called `input:keyboard/layout:set'."
                                          "Keybinds are: %S")
                  input//kl:layout/active
                  input//kl:layout:keybinds))

          ((not (input//kl:layout:valid/type? type))
           (error (input//kl:error/format func
                                          "Type '%S' is not a valid type. "
                                          "Must be one of: %S")
                  type input//kl:layout:types))

          (t
           ;; No errors - return something non-nil.
           type))))


(defun input:keyboard/layout:activate (bind/unbind types &optional no-eval)
  "Map the active keyboard layout's keybinds for each in supplied TYPE list.

BIND/UNBIND should be a valid keyword in `input//kl:bind/unbind'.

TYPES should be a list of keywords from `input//kl:layout:types'.

Return value will be either nil/non-nil (normally),
or `input//kl:layout:map-process' output if NO-EVAL is non-nil."
  ;;------------------------------
  ;; Error Checks happen in `input:keyboard/layout:activate',
  ;; but we need the canonical bind/unbind now so it'll get error checked here too.
  ;;------------------------------
  (let ((bind/unbind (input//kl:bind/unbind:valid? bind/unbind)) ;; Validates and canonicalizes.
        (debug/tags '(:registering :finalize))
        return-value)

    ;;------------------------------
    ;; First: Apply all TYPES unbindings.
    ;;------------------------------
    (when (memq bind/unbind '(:unbind :full))
      (dolist (type types)
        (push (input//kl:activate/type :unbind type no-eval debug/tags) return-value))
      ;; Did we succeed? How do we deal with `return-value'?
      (cond ((not return-value)
             (error (input//kl:error/format "input:keyboard/layout:activate"
                                            "Failed to activate unbindings.")))
            ((not no-eval)
             ;; Don't need to save these. Clear out for binding.
             (setq return-value nil)))
      ;; Do not set registering state for unbindings.
      )

    ;;------------------------------
    ;; Second: Apply all TYPES keybindings.
    ;;------------------------------
    (when (memq bind/unbind '(:bind :full))
      ;; Activate each type.
      (dolist (type types)
        (push (input//kl:activate/type :bind type no-eval debug/tags) return-value))

      ;; Prep return value?
      (unless no-eval
        (setq return-value (seq-reduce (lambda (x y)
                                         "Returns t/nil for (and x y)."
                                         (not (null (and x y))))
                                       return-value
                                       t)))

      ;; If we have a non-nil return we're `:active'.
      ;;
      ;; This will error out if invalid transition.
      (input//kl:layout:registering/set-if-valid? (if return-value
                                                      :active
                                                    :inactive)))

    ;;------------------------------
    ;; Done.
    ;;------------------------------
    ;; Small thing: if only unbinding, and we got here, and we have a nil
    ;; return-value and nil NO-EVAL... it's ok; that's valid. Change to t.
    (input//kl:debug
        "input:keyboard/layout:activate"
        debug/tags
      "Returning for `no-eval'=%S: return-value? %S, no-eval? %S, unbind? %S -> sexprs? %S"
      no-eval
      return-value
      no-eval
      bind/unbind
      (and (not return-value)
           (null no-eval)
           (eq bind/unbind :unbind)))
    (if (and (not return-value)
             (null no-eval)
             (eq bind/unbind :unbind))
        t
      return-value)))


(defun input//kl:activate/type (bind/unbind type &optional no-eval debug/tags)
  "Map the BINDINGS for TYPE.

BIND/UNBIND should be either `:bind' or `:unbind'. It will be used to determine
whether to get:
  - :bind   -> `input//kl:layout:keybinds'
  - :unbind -> `input//kl:layout:unbinds'

TYPE should be one of the keywords from `input//kl:layout:types'.

If NO-EVAL is non-nil, instead of mapping will return the code it would have used to map."
  (let ((valids:bind/unbind '(:bind :unbind))
        return-value)
    ;; We just apply the BINDINGS; what does `:full' mean in that context?
    (unless (memq bind/unbind valids:bind/unbind)
      (error (input//kl:error/format func
                                     "`bind/unbind' must be one of: %S")
             valids:bind/unbind))

    (if-let ((valid (input//kl:activate/validate "input//kl:activate/type"
                                                 bind/unbind type :active))
             ;; Could be this keybind has nothing for type, and that's fine...
             ;; It will error if there is nothing at all (e.g. layout never called `input:keyboard/layout:set'.
             (keybinds (input//kl:alist/get
                        type
                        (cond ((eq bind/unbind :bind)
                               input//kl:layout:keybinds)
                              ((eq bind/unbind :unbind)
                               input//kl:layout:unbinds)
                              (t
                               (error (input//kl:error/format
                                       func
                                       "`bind/unbind' must be one of: %S")
                                      '(:bind :unbind)))))))

        ;;------------------------------
        ;; Valid and have keybinds:
        ;;------------------------------
        (setq return-value
              ;; Return something non-nil.
              (or (prog1
                      ;; Should we do any sanity checks before `input//kl:layout:map-process' output is eval'd?
                      (if no-eval
                          ;; Not applying the keybinds - returning the sexprs instead.
                          (progn
                            (input//kl:debug
                                "input//kl:activate/type"
                                debug/tags
                              "no-eval input for map-process: %S" keybinds)
                            (input//kl:debug
                                "input//kl:activate/type"
                                debug/tags
                              "no-eval: %S"
                              (input//kl:layout:map-process keybinds))
                            (setq return-value (input//kl:layout:map-process keybinds)))
                        ;; We are applying the keybinds.
                        (input//kl:debug
                            "input//kl:activate/type"
                            debug/tags
                          "eval: %S"
                          (input//kl:layout:map-process keybinds))
                        (eval
                         ;; This is the function that actually creates the keybinds for `input:keyboard/layout:map!'.
                         ;; It'll return a `progn' of 'general' function calls, and we'll evaluate it.
                         (input//kl:layout:map-process keybinds))))
                  t))

      ;;------------------------------
      ;; Invalid or didn't find keybinds...
      ;;------------------------------
      (input//kl:debug
          "input//kl:activate/type"
          debug/tags
        (concat "Cannot activate keybinds for %S.\n"
                "  valid?    %S\n"
                "  keybinds: %S")
        type (not (null valid)) keybinds)
      ;; NOTE: Currently not an error as common/emacs may not have any keybinds.
      ;; Should probably return to being an error in the future?
      ;; (error (input//kl:error/format "input//kl:activate/type"
      ;;                                 "Cannot activate keybinds.\n"
      ;;                                 "  valid? %S\n"
      ;;                                 "  keybinds: %S")
      ;;        valid keybinds)

      ;; Return nil for invalid case.
      (setq return-value nil))

    (input//kl:debug
        "input//kl:activate/type"
        debug/tags
      "Returning for `no-eval': %S" no-eval)
    ;; Return t/nil normally, or the map-process output if `no-eval'.
    (if no-eval
        return-value
      (not (null return-value)))))


;;------------------------------------------------------------------------------
;; Testing
;;------------------------------------------------------------------------------

(defun input:keyboard/layout:set-registering (registering)
  "Allows forcing `input//kl:layout:registering' to a REGISTERING state."
  (interactive (list (completing-read "Registering State: "
                                      input//kl:layout:registering/states
                                      nil
                                      t
                                      ":temp")))
  (let ((prev input//kl:layout:registering)
        (registering (input//kl:normalize->keyword registering)))
    (setq input//kl:layout:registering registering)
    (message "Set registering to: %S (was %S)" registering prev)))


(defun input:keyboard/layout:apply (layout)
  "Initialize, configure, and apply the LAYOUT.

Overrides any current active layout with the new LAYOUT."
  ;; Could do a completing read or something with the valid layout dirs as the choices.
  (interactive (list (completing-read "Load Layout: "
                                      (input:keyboard/layout:list-layouts)
                                      nil
                                      t
                                      (when input//kl:layout/active
                                        (symbol-name input//kl:layout/active)))))

  ;; Change to our special `:apply' registering state so `:init' state will happen.

  (let ((registering/prev input//kl:layout:registering))
    (if (input//kl:layout:registering/set-if-valid? :apply)
        (message "Reset layout registration state: %S -> %S"
                 registering/prev input//kl:layout:registering)
      (message "Failed resetting registration state?! Shouldn't happen... state: %S -> %S"
               registering/prev input//kl:layout:registering)))

  ;; Check/report about desired.
  (let ((layout/keyword (input//kl:normalize->keyword layout)))
    ;; Updated desired first.
    (cond ((null input//kl:layout/desired)
           ;; Undefined
           (message "Setting desired keyboard layout: %S -> %S"
                    input//kl:layout/desired
                    layout/keyword))

          ((not (eq input//kl:layout/desired layout/keyword))
           (message "Changing desired keyboard layout: %S -> %S"
                    input//kl:layout/desired
                    layout/keyword))

          (t
           (message "Reapplying desired keyboard layout: %S -> %S"
                    input//kl:layout/desired
                    layout/keyword)))
    (setq input//kl:layout/desired layout/keyword)

    ;; Check/report about active.
    (cond ((null input//kl:layout/active)
           (message "Setting active keyboard layout: %S -> %S"
                    input//kl:layout/active
                    layout/keyword))
          ((not (eq input//kl:layout/active layout/keyword))
           (message "Changing active keyboard layout: %S -> %S"
                    input//kl:layout/active
                    layout/keyword))
          (t
           (message "Reapplying active keyboard layout: %S -> %S"
                    input//kl:layout/active
                    layout/keyword)))

    ;; Load active.
    (input:keyboard/layout:find-and-load-active "init") ;; This will set active.

    ;; Verify it was set before config/finalization.
    (if (not (eq input//kl:layout/active layout/keyword))
        ;; Fail message.
        (message (concat
                  "Initializing layout did not set it to the active layout?!\n"
                  "  Input:   %S\n"
                  "  Desired: %S\n"
                  "  Active:  %S")
                 layout/keyword
                 input//kl:layout/desired
                 input//kl:layout/active)

      ;; Config and finalize the new layout.
      (message "Configuring & binding %S..." input//kl:layout/active)
      (input:keyboard/layout:find-and-load-active "config")
      (input:keyboard/layout:finalize)
      (message "Loaded layout %S." input//kl:layout/active))))
;; (setq input//kl:layout/desired nil)
;; (setq input//kl:layout/active nil)


(defun input:keyboard/layout:clear ()
  "Clear the saved keybinds and unbinds.

Sets to nil:
  - `input//kl:layout:keybinds'
  - `input//kl:layout:unbinds'.

For e.g. resetting after a bad `input:keyboard/layout:temp'. You will have to
add back in all keybinds you want."
  (interactive)
  (setq input//kl:layout:unbinds nil)
  (setq input//kl:layout:keybinds nil))


(defun input:keyboard/layout:temp (bind/unbind eval/sexpr layout type keybind-map)
  "Allows changing an `input:keyboard/layout:set' to
`input:keyboard/layout:temp', running, and testing its keybinds.

BIND/UNBIND should be:
  - For binding:
    + `:bind'
    + `:set'
  - For unbinding:
    + `:unbind'
    + `:unset'

EVAL/RETURN should be:
  - For evaluating/applying layout: `:eval'
  - For getting layout sexprs returned: `:sexpr'
  - For getting layout sexprs pretty-printed: `:sexpr-pp'

LAYOUT should be a keyboard layout keyword.

TYPE should be one of the keywords from `input//kl:layout:types'.

KEYBIND-MAP should be a list of input to `input:keyboard/layout:map!'.

Does not run unless `input//kl:layout:registering' is `:active' or `:temp'.
  - That is: does not run temp blocks during Emacs/Doom start-up.

Calls:
  - `input:keyboard/layout:unset'
  - `input:keyboard/layout:set'
  - `input:keyboard/layout:config'
  - `input:keyboard/layout:activate'

For a complete activation of a keyboard layout, see `input:keyboard/layout:apply'."
  (declare (indent 4))

  (let ((bind/unbind (input//kl:bind/unbind:valid? bind/unbind))
        (no-eval (cond ((eq eval/sexpr :eval)
                        nil)
                       ((memq eval/sexpr '(:sexpr :pp-sexpr))
                        t)
                       (t
                        (error (input//kl:error/format
                                "input:keyboard/layout:temp"
                                "`eval/sexpr' must be one of: %S; "
                                "got: %S")
                               '(:eval :sexpr)
                               eval/sexpr))))
        (registering/valids (input//kl:layout:registering/get-valids :temp)))
    (input//kl:debug "input:keyboard/layout:temp"
        '(:registering)
      "map: %S" keybind-map)
    (input//kl:debug "input:keyboard/layout:temp"
        '(:registering)
      "registering: %S, valids: %S, valid? %S"
      input//kl:layout:registering
      (input//kl:layout:registering/get-valids :temp)
      (memq input//kl:layout:registering registering/valids))

    (if (not (memq input//kl:layout:registering
                   registering/valids))
        ;; We're not allowed to run the temp block.
        (progn
          (input//kl:debug "input:keyboard/layout:temp"
              '(:registering)
            (concat "Skipping this as not in a valid state for it:\n"
                    "registering: %S\n"
                    "valids:      %S\n"
                    "valid?       %S")
            input//kl:layout:registering
            registering/valids
            (memq input//kl:layout:registering registering/valids))

          ;; Explain why we're doing nothing.
          (input//kl:debug-or-message
              (format "input:keyboard/layout:temp(%S %S ...)" layout type)
              '(:register)
              ;; Message if not in some set-up state, else debug.
              (not (memq input//kl:layout:registering '(nil :init :config)))
            (concat "not run due to `%S's state %S. Set to one of these (can do via "
                    "`input:keyboard/layout:set-registering') to run: %S")
            'input//kl:layout:registering input//kl:layout:registering
            registering/valids))

      ;; We're allowed to run the temp block.
      (prog1
          (input//kl:debug "input:keyboard/layout:temp"
              '(:registering)
            (concat "EXECUTING ':temp' BLOCK!!!\n"
                    "registering: %S\n"
                    "valids:      %S\n"
                    "valid?       %S")
            input//kl:layout:registering
            registering/valids
            (memq input//kl:layout:registering registering/valids))

        ;; Have registering be `:temp' at start of each of these calls.
        (let ((input//kl:layout:registering :temp)
              return-value)
          ;; Apply the keybinds or unbinds.
          (cond ((eq bind/unbind :bind)
                 (input:keyboard/layout:bind layout type keybind-map))
                ((eq bind/unbind :unbind)
                 (input:keyboard/layout:unbind layout type keybind-map))
                (t
                 (error (input//kl:error/format
                         "input:keyboard/layout:temp"
                         "`bind/unbind' must be one of: %S. "
                         "Got: %S")
                        '(:bind :unbind)
                        bind/unbind)))
          ;; Config the keybinds.
          (input:keyboard/layout:config bind/unbind layout)
          ;; Activate the keybinds.
          (setq return-value
                (input:keyboard/layout:activate bind/unbind (list type) no-eval))
          (when (eq eval/sexpr :pp-sexpr)
            (pp-macroexpand-expression return-value))
          return-value)
        ;; Force to :temp.
        (input//kl:layout:registering/set-if-valid? :temp)))))


;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------
