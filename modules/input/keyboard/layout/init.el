;;; input/keyboard/layout/init.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                Build & Initialize the Keyboard Layout.                 ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                        Only for the desired layout.                        ;;
;;                                 ──────────                                 ;;


;; (+ivy/project-search nil "TODO" default-directory)


;;------------------------------------------------------------------------------
;; Layout Building Functions
;;------------------------------------------------------------------------------

;; Functions for both evil and emacs.
(load! "layout")


;;------------------------------------------------------------------------------
;; Layout Keyword -> Functions
;;------------------------------------------------------------------------------

(load! "common")

;; Include either evil or emacs keybinds, depending on if evil-mode is being
;; used.
(if (featurep! :editor evil)
    (load! "evil")
  (load! "emacs"))


;;------------------------------------------------------------------------------
;; Layout Inits
;;------------------------------------------------------------------------------

;; Find our active keyboard layout and load its init if it has one.
(keyboard:load:active "init")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
