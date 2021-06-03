;;; input/keyboard/layout/init.el -*- lexical-binding: t; -*-


;;                                  ──────────                                ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                        Keyboard Layout Builders                        ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                  ──────────                                ;;


;;------------------------------------------------------------------------------
;; Layout Building Functions
;;------------------------------------------------------------------------------

;; Functions for both evil and emacs.
(load! "layout")

;; Include either evil or emacs keybinds, depending on if evil-mode is being
;; used.
(if (featurep! :editor evil)
    (load! "evil")
  (load! "emacs"))


;;------------------------------------------------------------------------------
;; Layout Inits
;;------------------------------------------------------------------------------

;; Find our active keyboard layout and load its init if it has one.
(input:keyboard/layout:find-and-load-active "init")


;; ;;------------------------------
;; ;; Qwerty
;; ;;------------------------------
;; ;; Always need qwerty (right now) for unmapping help.
;; (input:keyboard/layout:load-file :qwerty "init")
;; ;; (input:keyboard/layout:load-active :qwerty "init")


;; ;;------------------------------
;; ;; Dvorak (Optional)
;; ;;------------------------------

;; ;; Normal Dvorak
;; (input:keyboard/layout:load-file :dvorak "init")

;; ;; Dvorak with non-standard keybinds of mine.
;; (input:keyboard/layout:load-file :spydez "init")


;; ;;------------------------------
;; ;; <NEXT LAYOUT> (Optional)
;; ;;------------------------------


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
