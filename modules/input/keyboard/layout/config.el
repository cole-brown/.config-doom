;;; input/keyboard/layout/config.el -*- lexical-binding: t; -*-

;;                                  ──────────                                ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                            Keyboard Layouts                            ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                  ──────────                                ;;


;;------------------------------------------------------------------------------
;; Required
;;------------------------------------------------------------------------------

;; Order matters.
;;   - But there are none right now, so.


;;------------------------------------------------------------------------------
;; Optional
;;------------------------------------------------------------------------------

;; None at the moment.


;;------------------------------------------------------------------------------
;; Config: Keyboard Layouts
;;------------------------------------------------------------------------------

;; Find our active keyboard layout and load its config if it has one.
(input:keyboard/layout:find-and-load-active "config")

;; ;;------------------------------
;; ;; Qwerty
;; ;;------------------------------
;; (input:keyboard/layout:load-active :qwerty "config")


;; ;;------------------------------
;; ;; Dvorak (Optional)
;; ;;------------------------------
;; ;; Normal Dvorak
;; (input:keyboard/layout:load-active :dvorak "config")

;; ;; Dvorak with non-standard keybinds of mine.
;; (input:keyboard/layout:load-active :spydez "config")


;; ;;------------------------------
;; ;; <NEXT LAYOUT> (Optional)
;; ;;------------------------------


;;------------------------------------------------------------------------------
;; Config: Set-Up Active Layout for Use
;;------------------------------------------------------------------------------

(defun input:keyboard/layout:finalize ()
  "Hook to run ONCE under `doom-init-modules-hook' for finalizing all
evil-mode keybinds. NOTE: ONLY CALL IF USING EVIL!"

  ;; Common first, then +good+ Emacs vs Evil.
  (input:keyboard/layout:activate :common)

  ;; Evil or Emacs? Only load one...
  (if (featurep! :editor evil)
      (input:keyboard/layout:activate :evil)
    (input:keyboard/layout:activate :emacs)))


;;------------------------------------------------------------------------------
;; Hooks
;;------------------------------------------------------------------------------

;; Don't mess with any of the hooks unless we're being evaluated during
;; start-up.
(when (input//kl:loading?)
  ;;------------------------------
  ;; Evil Itself
  ;;------------------------------

  ;; Allows us to have a list of functions to run under evil's
  ;; `evil-collection-setup-hook'.
  (fset 'input:keyboard/layout:evil-collection-setup-hook
        ;; Currently no functions, but if we have some it'll look like:
        ;; (input//kl:evil/setup:foo input//kl:evil/setup:bar)
        nil)


  ;;------------------------------
  ;; Doom, Post-Config
  ;;------------------------------

  ;; As a module, we cannot do our thing here - it could be too soon and we'd get
  ;; some/all of our keyboard layout overwritten by Doom. So we must delay until
  ;; the correct time.
  ;;
  ;; The existing ':input/layout' module uses this hooks, so we will too:
  (add-transient-hook!
      'doom-init-modules-hook
    ;; Finalize by actually finally mapping the layout's keybinds.
    (input:keyboard/layout:finalize)))

;; If testing, and you want to apply the keybind like the transient hook will,
;; just evaluate this:
;;   (input:keyboard/layout:finalize)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
