;;; input/keyboard/layout/config.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║               Configure & Finalize the Keyboard Layout.                ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;           Wait for the hook runs - then you're /actually/ done.            ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Config: Keyboard Layouts
;;------------------------------------------------------------------------------

;; Find our active keyboard layout and load its config if it has one.
(keyboard:load:active "config")


;;------------------------------------------------------------------------------
;; Config: Set-Up Active Layout for Use
;;------------------------------------------------------------------------------

(defun input:keyboard/layout:finalize ()
  "Hook to run ONCE under `doom-init-modules-hook' for finalizing all
evil-mode keybinds. NOTE: ONLY CALL IF USING EVIL!"

  ;; Common first, then +Good+ Emacs vs Evil.
  (let ((types '(:common)))
    ;; Evil or Emacs? Only load one...
    (if (featurep! :editor evil)
        (push :evil types)
      (push :emacs types))
    ;; Activate the keybinds for types.
    (int<keyboard>:layout:activate :actual :full types)))


;;------------------------------------------------------------------------------
;; Hooks
;;------------------------------------------------------------------------------

;; Don't mess with any of the hooks unless we're being evaluated during
;; start-up.
(when (and (not input//kl:testing:disable-start-up-init)
           (input//kl:loading?))
  ;;------------------------------
  ;; Evil Itself
  ;;------------------------------

  ;; Allows us to have a list of functions to run under evil's
  ;; `evil-collection-setup-hook'.
  ;; (fset 'input:keyboard/layout:evil-collection-setup-hook
  ;;       (
  ;;        ;; Currently no functions, but if we did, they'd just be in the list like:
  ;;        ;; input//kl:evil/setup:foo
  ;;        ;; input//kl:evil/setup:bar
  ;;       ))
  ;; (add-hook 'evil-collection-setup-hook
  ;;           #'input:keyboard/layout:evil-collection-setup-hook)


  ;;------------------------------
  ;; Doom, Post-Config
  ;;------------------------------

  ;; As a module, we cannot do our thing here - it could be too soon and we'd get
  ;; some/all of our keyboard layout overwritten by Doom. So we must delay until
  ;; the correct time.
  ;;
  ;; This Doom hook seems to be the proper one to use:
  (add-transient-hook!
      'doom-init-modules-hook
    ;; Finalize by actually finally mapping the layout's keybinds.
    (input:keyboard/layout:finalize)))

;;------------------------------
;; FOR TESTING LAYOUTS:
;;------------------------------
;; If testing, and you want to apply the keybind like the transient hook will,
;; just evaluate this:
;;   (input:keyboard/layout:finalize)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
