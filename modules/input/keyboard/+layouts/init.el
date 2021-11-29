;;; input/keyboard/+layouts/init.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                Build & Initialize the Keyboard Layout.                 ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                        Only for the desired layout.                        ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Active Layout Init!
;;------------------------------------------------------------------------------

;; Find our active keyboard layout and load its init if it has one.
(when (int<keyboard>:load:allowed? :init)
  (keyboard:load:active "init" :init))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard '+layouts 'init)
