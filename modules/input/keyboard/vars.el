;;; input/keyboard/vars.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                            Keyboard Layouts                            ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;             Not everyone uses Qwerty - there are dozens of us!             ;;
;;                                 ──────────                                 ;;

;; (imp:require :input 'keyboard 'alist)


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

(defun int<keyboard>:layout:type/valid? (type)
  "Returns non-nil if TYPE is a valid type.

See `int<keyboard>:layout:types for the alist of valid types."
  (int<keyboard>:alist:get/pair type int<keyboard>:layout:types))
;; (int<keyboard>:layout:type/valid? :emacs)


(defun int<keyboard>:layout:type->string (type)
  "Returns the string for TYPE keyword."
  ;; We have `int<keyboard>:layout:valid/type?' returning the alist entry.
  (cdr (int<keyboard>:layout:type/valid? type)))
;; (int<keyboard>:layout:type->string :emacs)


;;------------------------------
;; TESTING
;;------------------------------

;; TODO: Set back to nil when I figure out whatever's fucked up and fix it.
(defvar int<keyboard>:testing:disable-start-up-init nil
  "If non-nil, does not run anything during startup.
Just loads files to get all functions and such defined.")


;;------------------------------
;; Layout: Desired/Active
;;------------------------------

(defvar int<keyboard>:layout:desired nil
  "Cached :input/keyboard flag (converted to layout keyword) for desired
keyboard layout.

e.g. flag `+layout/dvorak' -> keyword `:dvorak'

'active' vs 'desired':
  - Desired is set from Doom module flags and comes from user.
  - Active is set in `input:keyboard/layout:set' when called by desired layout.
  - Both are set during 'init' file phase.")


(defvar int<keyboard>:layout:active nil
  "Cached keyword for the active/desired keyboard layout.

'active' vs 'desired':
  - Desired is set from Doom module flags and comes from user.
  - Active is set in `input:keyboard/layout:set' when called by desired layout
  - Both are set during 'init' file phase.")


(defun int<keyboard>:layout:valid? (layout &optional compare-active?)
  "Returns non-nil if LAYOUT is valid.

LAYOUT must fulfill these criteria:
  - Must be a keyword.
  - If `int<keyboard>:layout:desired' is set, LAYOUT must be `eq' to it (else we
    assume LAYOUT will become the desired layout).
  - If COMPARE-ACTIVE? is non-nil, LAYOUT must be `eq' to
   `int<keyboard>:layout:active'."
  (and (keywordp layout)
       ;; Equal to desired?
       (or (not int<keyboard>:layout:desired)
           (eq layout int<keyboard>:layout:desired))
       ;; Equal to active?
       (or (null compare-active?)
           (eq layout int<keyboard>:layout:active))))


;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------
;; (imp:provide :input 'keyboard 'vars)
