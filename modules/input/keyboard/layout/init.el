;;; input/keyboard/layout/init.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                Build & Initialize the Keyboard Layout.                 ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                        Only for the desired layout.                        ;;
;;                                 ──────────                                 ;;


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


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
