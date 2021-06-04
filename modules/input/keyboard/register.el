;;; input/keyboard/register.el -*- lexical-binding: t; -*-


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


(defconst input//kl:layout:types '(:common :emacs :evil)
  "Allowed types for a few function args, alist keys.

Types are:
  :common - Any keybinds that exist in both evil-mode and standard Emacs.
  :emacs  - Any Emacs-only keybinds (non-evil-mode).
  :evil   - Any Evil-only keybinds.")


;;------------------------------------------------------------------------------
;; Functions: Validity
;;------------------------------------------------------------------------------

(defun input//kl:layout:valid/type (type)
  "Returns non-nil if TYPE is a valid type.

See `input//kl:layout:types for the list of valid types."
  (memq type input//kl:layout:types))


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
  (declare (indent 1))
  (if (not (input//kl:valid/layout? layout))
      (error (input//kl:error-message "input:keyboard/layout:set"
                                      "`layout' must be a keyword. "
                                      "Got: %S")
             layout)
    (setq input//kl:layout/active layout))

  (if (not (input//kl:layout:valid/type type))
      (error (input//kl:error-message "input:keyboard/layout:set"
                                      "Type '%S' is not a valid type. "
                                      "Must be one of: %S")
             type input//kl:layout:types)
    (input//kl:alist/update type keybind-map input//kl:layout:keybinds t)))


;;------------------------------------------------------------------------------
;; Functions: Configuration
;;------------------------------------------------------------------------------

(defun input:keyboard/layout:config (layout)
  "Verifies that layout is still valid and is ready for finalization."

  ;;---
  ;; Can use finalization's check here w/ known-good type.
  ;;---
  (input//kl:activate/validate "input:keyboard/layout:config"
                               :common)

  ;;---
  ;; Also verify the `layout'.
  ;;---
  (unless (input//kl:valid/layout? layout :active)
    (error (input//kl:error-message "input:keyboard/layout:set"
                                    "`layout' must be a keyword. "
                                    "Got: %S")
           layout))

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
(defun input//kl:activate/validate (func type)
  "Checks that things are valid for `input:keyboard/layout:activate/<foo>' functions.

1. There must be an active layout.
2. Some keybinds must be set/saved.
3. TYPE must be valid."
  (cond ((null input//kl:layout/active)
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
        ((not (input//kl:layout:valid/type type))
         (error (input//kl:error-message func
                                         "Type '%S' is not a valid type. "
                                         "Must be one of: %S")
                type input//kl:layout:types))

        (t
         ;; No errors - return something non-nil.
         type)))


(defun input:keyboard/layout:activate (type)
  "Map the active keyboard layout's keybinds for TYPE."
  (when-let ((valid (input//kl:activate/validate "input:keyboard/layout:activate" type))
             ;; Could be this keybind has nothing for type, and that's fine...
             ;; It will error if there is nothing at all (e.g. layout never called `input:keyboard/layout:set'.
             (keybinds (input//kl:alist/get type input//kl:layout:keybinds)))

    ;; Should we do any sanity checks before `input//kl:layout:map-parse' output is eval'd?
    (eval
     ;; This is the function that actually creates the keybinds for `input:keyboard/layout:map!'.
     ;; It'll return a `progn' of 'general' function calls, and we'll evaluate it.
     (input//kl:layout:map-parse keybinds))))
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
;; The End
;;------------------------------------------------------------------------------
