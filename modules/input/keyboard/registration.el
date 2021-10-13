;;; input/keyboard/register.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                       Register to be The Layout.                       ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                           There can be only one.                           ;;
;;                                 ──────────                                 ;;


(imp:require :input 'keyboard 'registrars)


;;------------------------------------------------------------------------------
;; Functions: Bind / Unbind
;;------------------------------------------------------------------------------

(defun int<keyboard>:registration:valid/action? (keyword)
  "Valid actions are `:bind', `:unbind', and `:full'.

Returns nil if not valid."
  (memq keyword '(:bind :unbind :full)))
;; (int<keyboard>:registration:valid/action? :bind)
;; (int<keyboard>:registration:valid/action? :set)
;; (int<keyboard>:registration:valid/action? :jeff)
;; (int<keyboard>:registration:valid/action? :full)


;;------------------------------------------------------------------------------
;; Functions: Type Validity, etc.
;;------------------------------------------------------------------------------

;; TODO: move to registrar?
(defun input//kl:layout:valid/type? (type)
  "Returns non-nil if TYPE is a valid type.

See `int<keyboard>:layout:types for the alist of valid types."
  (input//kl:alist/entry type int<keyboard>:layout:types))
;; (input//kl:layout:valid/type? :emacs)


;; TODO: move to registrar?
(defun input//kl:layout:type->string (type)
  "Returns the string for TYPE keyword."
  ;; We have `input//kl:layout:valid/type?' returning the alist entry.
  (cdr (input//kl:layout:valid/type? type)))
;; (input//kl:layout:type->string :emacs)


;; TODO: move to registrar?
(defun input//kl:layout:registering/get-valids (desired)
  "Get the list of valid values current registration state can be for
entering DESIRED state."
  (alist-get desired int<keyboard>:registration:valid))


(defun input//kl:layout:registering/set-if-valid? (registrar to &optional no-set no-error)
  "Returns non-nil if transition of current registration state to new TO
state is valid.

If NO-SET is non-nil, skips setting current registration state.

If NO-ERROR is non-nil, will return nil instead of signaling an error."
  (let ((registration/current (int<keyboard>:registrar:get registrar :state)))
    ;; Check for errors.
    (cond ((not (memq registration/current
                      int<keyboard>:layout:registering/states))
           (int<keyboard>:debug
            "input//kl:layout:registering/set-if-valid?"
            '(:registering)
            "From (%S) is not a valid state: %S"
            registration/current
            int<keyboard>:layout:registering/states)
           nil)

          ((not (memq to int<keyboard>:layout:registering/states))
           (int<keyboard>:debug
            "input//kl:layout:registering/set-if-valid?"
            '(:registering)
            "To (%S) is not a valid state: %S"
            to
            int<keyboard>:layout:registering/states)
           nil)

          ;;------------------------------
          ;; Valid Cases:
          ;;------------------------------
          ;; Set to itself: ok.
          ((eq to registration/current)
           t)

          ;; Check for valid transition, set if found (and not `no-set').
          (t
           (let ((valid/froms (input//kl:layout:registering/get-valids to)))
             (if (not (memq registration/current valid/froms))
                 ;; Invalid transition - error or return nil.
                 (if no-error
                     nil
                   (int<keyboard>:output :error
                                         "input//kl:layout:registering/set-if-valid?"
                                         '("current registration state cannot transition from `%S' to `%S' state. "
                                           "Must be one of: %S")
                                         registration/current
                                         to
                                         valid/froms))
               ;; Valid. Check if we want to also set it, return non-nil.
               (unless no-set
                 (int<keyboard>:registrar:set registrar :state to)
                 (message "Set state to %S? %S"
                          to
                          (int<keyboard>:registrar:get registrar :state)))
               t))))))
;; (int<keyboard>:registrar:set :debug :state nil)
;; (int<keyboard>:registrar:get :debug :state)
;; (input//kl:layout:registering/set-if-valid? :debug :inactive t)
;; (int<keyboard>:registrar:get :debug :state)
;; (input//kl:layout:registering/set-if-valid? :debug :inactive)
;; (int<keyboard>:registrar:get :debug :state)
;; (input//kl:layout:registering/set-if-valid? :debug :active)
;; (input//kl:layout:registering/set-if-valid? :debug :active nil t)


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

(defun int<keyboard>:layout:bind (registrar layout type keybind-map)
  "Saves TYPE's KEYBIND-MAP for final configuration in
`int<keyboard>:layout:activate'.

REGISTRAR should be a keyword from `input//kl:registrars'.

TYPE should be one of:
  :common - Any keybinds that exist in both evil-mode and standard Emacs.
  :emacs  - Any Emacs-only keybinds (non-evil-mode).
  :evil   - Any Evil-only keybinds.

If called twice with the same TYPE, the later KEYBIND-MAP will overwrite the
earlier."
  (when (not (input//kl:valid/layout? layout))
    (int<keyboard>:output :error
                          "input:keyboard/layout:set"
                          '("`layout' must be a keyword. "
                            "Got: %S")
                          layout))

  (when (not (input//kl:layout:valid/type? type))
    (int<keyboard>:output :error
                          "input:keyboard/layout:set"
                          '("Type '%S' is not a valid type. "
                            "Must be one of: %S")
                          type int<keyboard>:layout:types))

  ;; Set to `:init' state unless we're in some finalized state. If we're in a finalized state,
  ;; just let the keymap be updated for possibly an `keyboard:layout:apply' or something.
  ;; TODO: move finalized states to a var.
  (unless (memq (int<keyboard>:registrar:get registrar :state) '(:active :inactive))
    ;; This will error out for us.
    (input//kl:layout:registering/set-if-valid? registrar :init))

  ;; Ok - errors checked; set it.
  (setq input//kl:layout/active layout)
  ;; Get the symbol name of the variable that stores these keybinds so we can use the alist helper macros to update it.
  (input//kl:alist/update type
                          keybind-map
                          (int<keyboard>:registrar:symbol registrar :keybinds)
                          t))


(defun keyboard:layout:bind (layout type keybind-map)
  "Saves TYPE's KEYBIND-MAP for final configuration in
`int<keyboard>:layout:activate'.

TYPE should be one of:
  :common - Any keybinds that exist in both evil-mode and standard Emacs.
  :emacs  - Any Emacs-only keybinds (non-evil-mode).
  :evil   - Any Evil-only keybinds.

If called twice with the same TYPE, the later KEYBIND-MAP will overwrite the
earlier."
  (declare (indent 2))
  (int<keyboard>:layout:bind :actual layout type keybind-map))
;; (pp-macroexpand-expression (int<keyboard>:registrar:get registrar :keybinds))


(defun int<keyboard>:layout:unbind (registrar layout type unbind-map)
  "Saves TYPE's UNBIND-MAP for final configuration in
`int<keyboard>:layout:activate'.

REGISTRAR should be a keyword from `input//kl:registrars'.

TYPE should be one of:
  :common - Any keybinds that exist in both evil-mode and standard Emacs.
  :emacs  - Any Emacs-only keybinds (non-evil-mode).
  :evil   - Any Evil-only keybinds.

If called twice with the same TYPE, the later UNBIND-MAP will overwrite the
earlier.

Unbindings are applied before bindings."
  (when (not (input//kl:valid/layout? layout))
    (int<keyboard>:output :error
                          "input:keyboard/layout:unbind"
                          '("`layout' must be a keyword. "
                            "Got: %S")
                          layout))

  (when (not (input//kl:layout:valid/type? type))
    (int<keyboard>:output :error
                          "input:keyboard/layout:unbind"
                          '("Type '%S' is not a valid type. "
                            "Must be one of: %S")
                          type int<keyboard>:layout:types))

  ;; Set to `:init' state unless we're in some finalized state. If we're in a finalized state,
  ;; just let the keymap be updated for possibly an `keyboard:layout:apply' or something.
  ;; TODO: move finalized states to a var.
  (unless (memq (int<keyboard>:registrar:get registrar :state) '(:active :inactive))
    ;; This will error out for us.
    (input//kl:layout:registering/set-if-valid? registrar :init))

  ;; Ok - errors checked; set it.
  (setq input//kl:layout/active layout)
  (input//kl:alist/update type unbind-map input//kl:layout:unbinds t))


(defun keyboard:layout:unbind (layout type unbind-map)
  "Saves TYPE's UNBIND-MAP for final configuration in
`int<keyboard>:layout:activate'.

TYPE should be one of:
  :common - Any keybinds that exist in both evil-mode and standard Emacs.
  :emacs  - Any Emacs-only keybinds (non-evil-mode).
  :evil   - Any Evil-only keybinds.

If called twice with the same TYPE, the later UNBIND-MAP will overwrite the
earlier.

Unbindings are applied before bindings."
  (declare (indent 2))
  (int<keyboard>:layout:unbind :actual layout type unbind-map))
;; (pp-macroexpand-expression (int<keyboard>:registrar:get registrar :unbinds))
;; (pp-macroexpand-expression (int<keyboard>:registrar:get registrar :keybinds))


;;------------------------------------------------------------------------------
;; Functions: Configuration
;;------------------------------------------------------------------------------

(defun int<keyboard>:layout:config (registrar bind/unbind layout)
  "Verifies that LAYOUT is still valid and is ready for finalization.

REGISTRAR should be a keyword from `input//kl:registrars'.

BIND/UNBIND should be a valid keyword in `int<keyboard>:registration:action'.

LAYOUT should be a valid keyboard layout keyword."
  ;;---
  ;; Can use finalization's check here w/ known-good type.
  ;;---
  (input//kl:activate/validate "keyboard:layout:config"
                               registrar
                               bind/unbind
                               :common
                               :config)

  ;;---
  ;; Also verify the `layout'.
  ;;---
  (unless (input//kl:valid/layout? layout :active)
    (int<keyboard>:output :error
                          "input:keyboard/layout:set"
                          '("`layout' must be a keyword. "
                            "Got: %S")
                          layout))

  ;; This will error out for us.
  (input//kl:layout:registering/set-if-valid? registrar :config)

  ;;------------------------------
  ;; Configuration
  ;;------------------------------
  ;; Nothing to do, currently.
  ;;
  ;; Only steps that need to happen after `input:keyboard/layout:set' is the
  ;; `int<keyboard>:layout:activate', which happens in Finalization.
  ;;
  ;; NOTE: If we get something to do: obey `bind/unbind'!
  )


(defun keyboard:layout:config (bind/unbind layout)
  "Verifies that LAYOUT is still valid and is ready for finalization.

BIND/UNBIND should be a valid keyword in `int<keyboard>:registration:action'.

LAYOUT should be a valid keyboard layout keyword."
  (int<keyboard>:layout:config :actual bind/unbind layout))


;;------------------------------------------------------------------------------
;; Functions: Finalization
;;------------------------------------------------------------------------------

;; Also used in config step, currently, but could make that have its own checks
;; if this needs to change to be specific to finalization.
(defun input//kl:activate/validate (caller registrar bind/unbind type registering)
  "Checks that things are valid for `int<keyboard>:layout:activate'.

1. There must be an active layout.
2. Some keybinds must be set/saved.
3. BIND/UNBIND must be valid
4. TYPE must be valid.
5. current registration state must be able to transition to REGISTERING.

CALLER should be the function name of the caller.

BIND/UNBIND should be a valid keyword in `int<keyboard>:registration:action'.

TYPE should be one of the keywords from `int<keyboard>:layout:types'.

REGISTERING should be a registering state (see `int<keyboard>:layout:registering/states')."
  (cond ((not (int<keyboard>:registration:valid/action? bind/unbind))
         ;; Should have already signaled an error if invalid, but to be extra cautious:
         (int<keyboard>:output :error
                               caller
                               '("Invalid bind/unbind keyword `%S'.")
                               bind/unbind))

        ((not (input//kl:layout:registering/set-if-valid? registrar registering 'no-set))
         ;; set-if-valid? will signal error, so no need to do it again.
         (int<keyboard>:output :error
                               caller
                               '("Cannot transition registering state %S -> %S.")
                               (int<keyboard>:registrar:get registrar :state)
                               registering))

        ((null input//kl:layout/active)
         (int<keyboard>:output :error
                               caller
                               '("No active layout set; cannot configure keyboard layout! "
                                 "desired: '%S', "
                                 "active:  '%S'")
                               input//kl:layout/desired
                               input//kl:layout/active))

        ;; If we're binding, we need keys to bind.
        ;;   - If we're unbinding, though, we are ok with not having anything to unbind.
        ((and (memq canon:bind/unbind '(:bind :full))
              (null (int<keyboard>:registrar:get registrar :keybinds)))
         (int<keyboard>:output :error
                               caller
                               '("Active layout has not set its keybinds; "
                                 "cannot configure keyboard layout! "
                                 "Expected %S to have called `input:keyboard/layout:set'."
                                 "Keybinds are: %S")
                               input//kl:layout/active
                               (int<keyboard>:registrar:get registrar :keybinds)))

        ((not (input//kl:layout:valid/type? type))
         (int<keyboard>:output :error
                               caller
                               '("Type '%S' is not a valid type. "
                                 "Must be one of: %S")
                               type int<keyboard>:layout:types))

        (t
         ;; No errors - return something non-nil.
         type)))


(defun int<keyboard>:layout:activate (registrar bind/unbind types &optional no-eval)
  "Map the active keyboard layout's keybinds for each in supplied TYPE list.

BIND/UNBIND should be a valid keyword in `int<keyboard>:registration:action'.

TYPES should be a list of keywords from `int<keyboard>:layout:types'.

Return value will be either nil/non-nil (normally),
or `input//kl:layout:map-process' output if NO-EVAL is non-nil."
  (let ((func.name "int<keyboard>:layout:activate")
        (debug/tags '(:registering :finalize))
        return-value)

    ;; Validate inputs.
    (int<keyboard>:registration:valid/action? bind/unbind)

    ;;------------------------------
    ;; First: Apply all TYPES unbindings.
    ;;------------------------------
    (when (memq bind/unbind '(:unbind :full))
      (dolist (type types)
        (push (input//kl:activate/type :unbind type no-eval debug/tags) return-value))

      ;; Did we succeed? How do we deal with `return-value'?
      (cond ((not return-value)
             (int<keyboard>:output :error
                                   func.name
                                   '("Failed to activate unbindings.")))
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
      (input//kl:layout:registering/set-if-valid? registrar
                                                  (if return-value
                                                      :active
                                                    :inactive)))

    ;;------------------------------
    ;; Done.
    ;;------------------------------
    ;; Small thing: if only unbinding, and we got here, and we have a nil
    ;; return-value and nil NO-EVAL... it's ok; that's valid. Change to t.
    (int<keyboard>:debug
     func.name
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
  - :bind   -> `(int<keyboard>:registrar:get registrar :keybinds)'
  - :unbind -> `(int<keyboard>:registrar:get registrar :unbinds)'

TYPE should be one of the keywords from `int<keyboard>:layout:types'.

If NO-EVAL is non-nil, instead of mapping will return the code it would have used to map."
  (let ((valids:bind/unbind '(:bind :unbind))
        return-value)
    ;; We just apply the BINDINGS; what does `:full' mean in that context?
    (unless (memq bind/unbind valids:bind/unbind)
      (int<keyboard>:output :error
                            func
                            '("`bind/unbind' must be one of: %S")
                            valids:bind/unbind))

    (if-let ((valid (input//kl:activate/validate "input//kl:activate/type"
                                                 registrar bind/unbind type :active))
             ;; Could be this keybind has nothing for type, and that's fine...
             ;; It will error if there is nothing at all (e.g. layout never called `input:keyboard/layout:set'.
             (keybinds (input//kl:alist/get
                        type
                        (cond ((eq bind/unbind :bind)
                               (int<keyboard>:registrar:get registrar :keybinds))
                              ((eq bind/unbind :unbind)
                               (int<keyboard>:registrar:get registrar :unbinds))
                              (t
                               (int<keyboard>:output :error
                                                     func
                                                     "`bind/unbind' must be one of: %S"
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
                            (int<keyboard>:debug
                             "input//kl:activate/type"
                             debug/tags
                             "no-eval input for map-process: %S" keybinds)
                            (int<keyboard>:debug
                             "input//kl:activate/type"
                             debug/tags
                             "no-eval: %S"
                             (input//kl:layout:map-process keybinds))
                            (setq return-value (input//kl:layout:map-process keybinds)))
                        ;; We are applying the keybinds.
                        (int<keyboard>:debug
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
      (int<keyboard>:debug
       "input//kl:activate/type"
       debug/tags
       (concat "Cannot activate keybinds for %S.\n"
               "  valid?    %S\n"
               "  keybinds: %S")
       type (not (null valid)) keybinds)
      ;; NOTE: Currently not an error as common/emacs may not have any keybinds.
      ;; Should probably return to being an error in the future?
      ;; (int<keyboard>:output :error
      ;;                       "input//kl:activate/type"
      ;;                       '("Cannot activate keybinds.\n"
      ;;                         "  valid? %S\n"
      ;;                         "  keybinds: %S")
      ;;                       valid keybinds)

      ;; Return nil for invalid case.
      (setq return-value nil))

    (int<keyboard>:debug
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

(defun test<keyboard>:layout:set-registering (registering)
  "Allows forcing current registration state to a REGISTERING state."
  (interactive (list (completing-read "Registering State: "
                                      int<keyboard>:layout:registering/states
                                      nil
                                      t
                                      ":init")))
  (let ((prev (int<keyboard>:registrar:get registrar :state))
        (registering (input//kl:normalize->keyword registering)))
    (int<keyboard>:registrar:set registrar :state registering)
    (message "Set registering to: %S (was %S)" registering prev)))

(defun keyboard:layout:apply (layout)
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

  (let ((registrar :actual)
        (registering/prev (int<keyboard>:registrar:get registrar :state)))
    (if (input//kl:layout:registering/set-if-valid? registrar :apply)
        (message "Reset layout registration state: %S -> %S"
                 registering/prev (int<keyboard>:registrar:get registrar :state))
      (message "Failed resetting registration state?! Shouldn't happen... state: %S -> %S"
               registering/prev (int<keyboard>:registrar:get registrar :state))))

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
;; (keyboard:layout:clear)


(defun keyboard:layout:clear ()
  "Clear the saved keybinds and unbinds.

Sets to nil:
  - `(int<keyboard>:registrar:get registrar :keybinds)'
  - `(int<keyboard>:registrar:get registrar :unbinds)'.

For e.g. resetting after a bad testing command. You will have to
add back in all keybinds you want."
  (interactive)
  ;; Reset all registrars or just one given registrar?
  ;;  - Both if no input, one if input?
  ;; Let's just go with reset all of them for now.
  (dolist (registrar (mapcar (lambda (registrar-assoc)
                               "Get registrar keywords."
                               (car registrar-assoc))
                             input//kl:registrars))
    (int<keyboard>:registrar:set registrar :unbinds nil)
    (int<keyboard>:registrar:set registrar :keybinds nil)))


(defun test<keyboard>:layout:bind (eval/sexpr layout type keybind-map)
  "Allows changing an `input:keyboard/layout:set' to
`test<keyboard>:layout:bind', running, and testing its keybinds.

EVAL/RETURN should be:
  - For evaluating/applying layout: `:eval'
  - For getting layout sexprs returned: `:sexpr'
  - For getting layout sexprs pretty-printed: `:sexpr-pp'

LAYOUT should be a keyboard layout keyword.

TYPE should be one of the keywords from `int<keyboard>:layout:types'.

KEYBIND-MAP should be a list of input to `input:keyboard/layout:map!'.

Does not run unless current registration state is `:active'.
  - That is: does not run temp blocks during Emacs/Doom start-up.

Calls:
  - `input:keyboard/layout:unbind'
  - `input:keyboard/layout:set'
  - `keyboard:layout:config'
  - `int<keyboard>:layout:activate'

For a complete activation of a keyboard layout, see `keyboard:layout:apply'."
  (declare (indent 3))

  (let* ((func.name "test<keyboard>:layout:bind")
         (registrar :temp) ;; Do all this work in the temp registrar.
         (registration/current (int<keyboard>:registrar:get registrar :state))
         (no-eval (cond ((eq eval/sexpr :eval)
                         nil)
                        ((memq eval/sexpr '(:sexpr :pp-sexpr))
                         t)
                        (t
                         (int<keyboard>:output :error
                                               func.name
                                               '("`eval/sexpr' must be one of: %S; "
                                                 "got: %S")
                                               '(:eval :sexpr)
                                               eval/sexpr)))))

    (int<keyboard>:debug func.name
                         '(:registering)
                         "map: %S" keybind-map)
    (int<keyboard>:debug func.name
                         '(:registering)
                         "registering: %S, valids: %S, valid? %S"
                         registration/current
                         registration/valids
                         (memq registration/current registration/valids))

    (if (not (memq registration/current
                   registration/valids))
        ;; [FAIL]: Current registration state doesn't allowed running the temp block.
        (progn
          (int<keyboard>:debug func.name
                               '(:registering)
                               (concat "Skipping this as not in a valid state for it:\n"
                                       "registering: %S\n"
                                       "valids:      %S\n"
                                       "valid?       %S")
                               registration/current
                               registration/valids
                               (memq registration/current registration/valids))

          ;; Explain why we're doing nothing.
          (int<keyboard>:debug/message?
           (format "%s(%S %S ...)" func.name layout type)
           '(:register)
           ;; Message if not in some set-up state, else debug.
           (not (memq registration/current '(nil :init :config)))
           (concat "not run due to current registration state %S. "
                   "Set to one of these (can do via "
                   "`test<keyboard>:layout:set-registering') to run: %S")
           registration/current
           registration/valids))

      ;; [ OK ]: Run the temp block.
      (prog1
          (int<keyboard>:debug func.name
                               '(:registering)
                               (concat "EXECUTING 'temp binds' BLOCK!!!\n"
                                       "registering: %S\n"
                                       "valids:      %S\n"
                                       "valid?       %S")
                               registration/current
                               registration/valids
                               (memq registration/current registration/valids))

        (let (return-value)
          ;; Apply the keybinds.
          (keyboard:layout:bind layout type keybind-map)

          ;;---
          ;; Since we're testing this block, always continue on to config & activation.
          ;;---

          ;; Config the keybinds.
          (keyboard:layout:config bind/unbind layout)

          ;; Activate the keybinds.
          (setq return-value
                (int<keyboard>:layout:activate registrar bind/unbind (list type) no-eval))
          (when (eq eval/sexpr :pp-sexpr)
            (pp-macroexpand-expression return-value))
          return-value)))))


(defun test<keyboard>:layout:unbind (eval/sexpr layout type keybind-map)
  "Allows changing an `input:keyboard/layout:set' to
`test<keyboard>:layout:bind', running, and testing its keybinds.

EVAL/RETURN should be:
  - For evaluating/applying layout: `:eval'
  - For getting layout sexprs returned: `:sexpr'
  - For getting layout sexprs pretty-printed: `:sexpr-pp'

LAYOUT should be a keyboard layout keyword.

TYPE should be one of the keywords from `int<keyboard>:layout:types'.

KEYBIND-MAP should be a list of input to `input:keyboard/layout:map!'.

Does not run unless current registration state is `:active'.
  - That is: does not run temp blocks during Emacs/Doom start-up.

Calls:
  - `input:keyboard/layout:unbind'
  - `input:keyboard/layout:set'
  - `keyboard:layout:config'
  - `int<keyboard>:layout:activate'

For a complete activation of a keyboard layout, see `keyboard:layout:apply'."
  (declare (indent 3))

  (let* ((func.name "test<keyboard>:layout:unbind")
         (registrar :temp) ;; Do all this work in the temp registrar.
         (registration/current (int<keyboard>:registrar:get registrar :state))
         (no-eval (cond ((eq eval/sexpr :eval)
                         nil)
                        ((memq eval/sexpr '(:sexpr :pp-sexpr))
                         t)
                        (t
                         (int<keyboard>:output :error
                                               func.name
                                               '("`eval/sexpr' must be one of: %S; "
                                                 "got: %S")
                                               '(:eval :sexpr)
                                               eval/sexpr)))))

    (int<keyboard>:debug func.name
                         '(:registering)
                         "map: %S" keybind-map)
    (int<keyboard>:debug func.name
                         '(:registering)
                         "registering: %S, valids: %S, valid? %S"
                         registration/current
                         registration/valids
                         (memq registration/current registration/valids))

    (if (not (memq registration/current
                   registration/valids))
        ;; [FAIL]: Current registration state doesn't allowed running the temp block.
        (progn
          (int<keyboard>:debug func.name
                               '(:registering)
                               (concat "Skipping this as not in a valid state for it:\n"
                                       "registering: %S\n"
                                       "valids:      %S\n"
                                       "valid?       %S")
                               registration/current
                               registration/valids
                               (memq registration/current registration/valids))

          ;; Explain why we're doing nothing.
          (int<keyboard>:debug/message?
           (format "%s(%S %S ...)" func.name layout type)
           '(:register)
           ;; Message if not in some set-up state, else debug.
           (not (memq registration/current '(nil :init :config)))
           (concat "not run due to current registration state %S. "
                   "Set to one of these (can do via "
                   "`test<keyboard>:layout:set-registering') to run: %S")
           registration/current
           registration/valids))

      ;; [ OK ]: Run the temp block.
      (prog1
          (int<keyboard>:debug func.name
                               '(:registering)
                               (concat "EXECUTING 'temp binds' BLOCK!!!\n"
                                       "registering: %S\n"
                                       "valids:      %S\n"
                                       "valid?       %S")
                               registration/current
                               registration/valids
                               (memq registration/current registration/valids))

        (let (return-value)
          ;; Apply the unbinds.
          (keyboard:layout:unbind layout type keybind-map)

          ;;---
          ;; Since we're testing this block, always continue on to config & activation.
          ;;---

          ;; Config the keybinds.
          (keyboard:layout:config bind/unbind layout)

          ;; Activate the keybinds.
          (setq return-value
                (int<keyboard>:layout:activate registrar bind/unbind (list type) no-eval))
          (when (eq eval/sexpr :pp-sexpr)
            (pp-macroexpand-expression return-value))
          return-value)))))


;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard 'registration)
