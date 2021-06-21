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
and `input//kl:layout:registering/valid->temp'):
  nil - Nothing has happened yet.
  :init - Initialization happened.
  :config - Configuration happened.
  :active - Activation/finalization happened w/ valid keybinds.
  :inactive - Activation/finalization happened w/o valid keybinds.
  :temp - Someone called `input:keyboard/layout:temp'.")


(defconst input//kl:layout:registering/states
  '(nil
    :init
    :config
    :active
    :inactive
    :temp)
  "All valid values for `input//kl:layout:registering'.")


(defconst input//kl:layout:registering/valid
  ;; (state    . (list of valid states to transition from))
  '((nil       . (nil :temp))
    (:init     . (nil :temp))
    (:config   . (:init :temp))
    (:active   . (:config :temp))
    (:inactive . (nil :init :config :temp))
    (:temp     . (nil :init :config :active :inactive :temp)))
  "Alist of all valid values for moving `input//kl:layout:registering'
to a certain state.")


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


(defun input//kl:layout:registering/set-if-valid? (to &optional no-set no-error)
  "Returns non-nil if transition of `input//kl:layout:registering' to new TO
state is valid.

If NO-SET is non-nil, skips setting `input//kl:layout:registering'.

If NO-ERROR is non-nil, will return nil instead of signaling an error."
  (cond ((not (memq input//kl:layout:registering
                    input//kl:layout:registering/states))
         (message "From (%S) is not a valid state: %S"
                  input//kl:layout:registering
                  input//kl:layout:registering/states)
         nil)
        ((not (memq to input//kl:layout:registering/states))
         (message "To (%S) is not a valid state: %S"
                  to
                  input//kl:layout:registering/states)
         nil)
        (t
         (let ((valid/froms (alist-get to input//kl:layout:registering/valid)))
           (if (not (memq input//kl:layout:registering valid/froms))
               ;; Invalid transition - error or return nil.
               (if no-error
                   nil
                 (error (input//kl:error-message "input//kl:layout:registering/set-if-valid?"
                                                 "`input//kl:layout:registering' (`%S') cannot transition to `%S' state. "
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


;;------------------------------------------------------------------------------
;; Functions: Initialization
;;------------------------------------------------------------------------------

(defun input:keyboard/layout:set (layout type keybind-map)
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
    (error (input//kl:error-message "input:keyboard/layout:set"
                                    "`layout' must be a keyword. "
                                    "Got: %S")
           layout))

  (when (not (input//kl:layout:valid/type? type))
    (error (input//kl:error-message "input:keyboard/layout:set"
                                    "Type '%S' is not a valid type. "
                                    "Must be one of: %S")
           type input//kl:layout:types))

  ;; This will error out for us.
  (input//kl:layout:registering/set-if-valid? :init)

  ;; Ok - errors checked; set it.
  (setq input//kl:layout/active layout)
  (input//kl:alist/update type keybind-map input//kl:layout:keybinds t))


;;------------------------------------------------------------------------------
;; Functions: Configuration
;;------------------------------------------------------------------------------

(defun input:keyboard/layout:config (layout)
  "Verifies that layout is still valid and is ready for finalization."

  ;;---
  ;; Can use finalization's check here w/ known-good type.
  ;;---
  (input//kl:activate/validate "input:keyboard/layout:config"
                               :common
                               :config)

  ;;---
  ;; Also verify the `layout'.
  ;;---
  (unless (input//kl:valid/layout? layout :active)
    (error (input//kl:error-message "input:keyboard/layout:set"
                                    "`layout' must be a keyword. "
                                    "Got: %S")
           layout))

  ;; This will error out for us.
  (input//kl:layout:registering/set-if-valid? :config)

  ;;------------------------------
  ;; Configuration
  ;;------------------------------
  ;; Nothing to do, currently.
  ;; Only steps that need to happen after `input:keyboard/layout:set' is the
  ;; `input:keyboard/layout:activate', which happens in Finalization.
  )


;;------------------------------------------------------------------------------
;; Functions: Finalization
;;------------------------------------------------------------------------------

;; Also used in config step, currently, but could make that have its own checks
;; if this needs to change to be specific to finalization.
(defun input//kl:activate/validate (func type registering)
  "Checks that things are valid for `input:keyboard/layout:activate/<...>' functions.

1. There must be an active layout.
2. Some keybinds must be set/saved.
3. TYPE must be valid.
4. `input//kl:layout:registering' must be able to transition to REGISTERING."
  (cond ((not (input//kl:layout:registering/set-if-valid? registering 'no-set))
         ;; set-if-valid? will signal error, so no need to do it again.
         (error (input//kl:error-message func
                                         "Cannot transition registering state %S -> %S.")
                input//kl:layout:registering
                registering))

        ((null input//kl:layout/active)
         (error (input//kl:error-message func
                                         "No active layout set; cannot configure keyboard layout! "
                                         "desired: '%S', "
                                         "active:  '%S'")
                input//kl:layout/desired
                input//kl:layout/active))

        ((null input//kl:layout:keybinds)
         (error (input//kl:error-message func
                                         "Active layout has not set its keybinds; "
                                         "cannot configure keyboard layout! "
                                         "Expected %S to have called `input:keyboard/layout:set'."
                                         "Keybinds are: %S")
                input//kl:layout/active
                input//kl:layout:keybinds))
        ((not (input//kl:layout:valid/type? type))
         (error (input//kl:error-message func
                                         "Type '%S' is not a valid type. "
                                         "Must be one of: %S")
                type input//kl:layout:types))

        (t
         ;; No errors - return something non-nil.
         type)))


(defun input:keyboard/layout:activate (type &optional no-eval)
  "Map the active keyboard layout's keybinds for TYPE."
  (let (return-value)
    (if-let ((valid (input//kl:activate/validate "input:keyboard/layout:activate"
                                                 type :active))
             ;; Could be this keybind has nothing for type, and that's fine...
             ;; It will error if there is nothing at all (e.g. layout never called `input:keyboard/layout:set'.
             (keybinds (input//kl:alist/get type input//kl:layout:keybinds)))
        (progn
          ;; Should we do any sanity checks before `input//kl:layout:map-process' output is eval'd?
          (if no-eval
              (setq return-value (input//kl:layout:map-process keybinds))
            (eval
             ;; This is the function that actually creates the keybinds for `input:keyboard/layout:map!'.
             ;; It'll return a `progn' of 'general' function calls, and we'll evaluate it.
             (input//kl:layout:map-process keybinds)))

          ;; We are now active.
          ;;
          ;; This will error out if invalid.
          (input//kl:layout:registering/set-if-valid? :active))

      ;; This will error out if invalid.
      (input//kl:layout:registering/set-if-valid? :inactive)
      ;; No valid keybinds.
      (error (input//kl:error-message "input:keyboard/layout:activate"
                                      "Cannot activate keybinds.\n"
                                      "  valid? %S\n"
                                      "  keybinds: %S")
             valid keybinds))

    ;; Return active/inactive normally, or the map-process output if `no-eval'.
    (if no-eval
        return-value
      input//kl:layout:registering)))
;; (input:keyboard/layout:activate :common)
;; (input:keyboard/layout:activate :emacs)
;; (input:keyboard/layout:activate :evil)
;; (input:keyboard/layout:activate :INVALID)
;; (input:keyboard/layout:map!
;;  :nvm  "c"  #'evil-previous-line
;;  :nvm  "t"  #'evil-next-line
;;  :nvm  "h"  #'evil-backward-char
;;  :nvm  "n"  #'evil-forward-char)


;;------------------------------------------------------------------------------
;; Testing
;;------------------------------------------------------------------------------

(defun input:keyboard/layout:temp (layout type keybind-map)
  "Allows changing an `input:keyboard/layout:set' to
`input:keyboard/layout:test', running, and testing its keybinds.

Does not run unless `input//kl:layout:registering' is `:active' or `:temp'.
  - That is: does not run temp blocks during Emacs/Doom start-up.

Calls:
  - `input:keyboard/layout:set'
  - `input:keyboard/layout:config'
  - `input:keyboard/layout:activate'"
  (declare (indent 2))
  (if (not (memq input//kl:layout:registering input//kl:layout:registering/valid->temp))
      ;; Explain why we're doing nothing.
      (message (concat "input:keyboard/layout:temp(%S %S ...) not run due to "
                       "`%S's state %S. Set to one of these to run: %S")
               layout type
               'input//kl:layout:registering input//kl:layout:registering
               input//kl:layout:registering/valid->temp)
    (prog1
        ;; Have registering be `:temp' at start of each of these calls.
        (let ((input//kl:layout:registering :temp))
          ;; Apply the keybinds.
          (input:keyboard/layout:set layout type keybind-map)
          ;; Config the keybinds.
          (input:keyboard/layout:config layout)
          ;; Activate the keybinds.
          (input:keyboard/layout:activate type)) ;; 'no-eval))
      ;; Force to :temp.
      (input//kl:layout:registering/set-if-valid? :temp))))


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


;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------
