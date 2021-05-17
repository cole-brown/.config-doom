;;; input/keyboard/config.el -*- lexical-binding: t; -*-


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

;;------------------------------
;; Qwerty
;;------------------------------
;; Always need qwerty (right now) for unmapping help.
(load! "layout/qwerty/config")
;; (input:keyboard/layout:load-if :qwerty "config")


;;------------------------------
;; Dvorak (Optional)
;;------------------------------
;; Normal Dvorak
(input:keyboard/layout:load-if :dvorak "config")

;; Dvorak with non-standard keybinds of mine.
(input:keyboard/layout:load-if :spydez "config")


;;------------------------------
;; <NEXT LAYOUT> (Optional)
;;------------------------------


;;------------------------------------------------------------------------------
;; Config: Set-Up Active Layout for Use
;;------------------------------------------------------------------------------

(defun input:keyboard/layout:finalize/always ()
  "Hook to run ONCE under `doom-init-modules-hook' for finalizing all
keybinds that don't care about evil vs good."
  ;; Nothing to do at the moment.
  )


(defun input:keyboard/layout:finalize/evil ()
  "Hook to run ONCE under `doom-init-modules-hook' for finalizing all
evil-mode keybinds. NOTE: ONLY CALL IF USING EVIL!"
  ;; TODO: rename stuff for evil vs non-evil.
  (input:keyboard/layout:configure-active))


;;------------------------------------------------------------------------------
;; Hooks
;;------------------------------------------------------------------------------

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

(add-transient-hook!
    'doom-init-modules-hook
  (input:keyboard/layout:finalize/always))


(when (featurep! :editor evil)
  (add-transient-hook!
      'doom-init-modules-hook
    (input:keyboard/layout:finalize/evil)))

;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
