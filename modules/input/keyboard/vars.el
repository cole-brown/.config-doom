;;; input/keyboard/vars.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                            Keyboard Layouts                            ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;             Not everyone uses Qwerty - there are dozens of us!             ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

;;------------------------------
;; Layout Types
;;------------------------------

(defconst int<keyboard>:layout:types '((:common . "common")
                                       (:emacs  . "emacs")
                                       (:evil   . "evil"))
  "Allowed types for a few function args, alist keys.

Types are:
  :common - Any keybinds that exist in both evil-mode and standard Emacs.
  :emacs  - Any Emacs-only keybinds (non-evil-mode).
  :evil   - Any Evil-only keybinds.")
;; int<keyboard>:layout:types
;; (makunbound 'int<keyboard>:layout:types)


;;------------------------------
;; TESTING
;;------------------------------

(defvar input//kl:testing:disable-start-up-init nil
  "If non-nil, does not run anything during startup.
Just loads files to get all functions and such defined.")


;;------------------------------
;; Layout: Desired/Active
;;------------------------------

(defvar input//kl:layout/desired nil
  "Cached :input/keyboard flag (converted to layout keyword) for desired
keyboard layout.

e.g. flag `+layout/dvorak' -> keyword `:dvorak'

'active' vs 'desired':
  - Desired is set from Doom module flags and comes from user.
  - Active is set in `input:keyboard/layout:set' when called by desired layout.
  - Both are set during 'init' file phase.")


(defvar input//kl:layout/active nil
  "Cached keyword for the active/desired keyboard layout.

'active' vs 'desired':
  - Desired is set from Doom module flags and comes from user.
  - Active is set in `input:keyboard/layout:set' when called by desired layout
  - Both are set during 'init' file phase.")
