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

(load! "derive")
(load! "types/init")
(load! "layout")
(load! "bind")
(load! "bind-debug")

;;------------------------------------------------------------------------------
;; Provide
;;------------------------------------------------------------------------------
;; We've loaded all of the library/module/whatever.
;; Provide our symbol to indicate we're done.
(imp:provide :input 'keyboard 'layout)


;;------------------------------------------------------------------------------
;; Layout Inits
;;------------------------------------------------------------------------------

;; Find our active keyboard layout and load its init if it has one.
(when (int<keyboard>:load:allowed? :init)
  (keyboard:load:active "init" :init))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
