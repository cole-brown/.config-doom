;;; input/keyboard/layout/qwerty/config.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                                 Qwerty                                 ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;       Typewriters needed to be slow, so let's just stick with that.        ;;
;;                                 ──────────                                 ;;

;; Should be done with all the 'config' of ':input/keyboard'.
(imp:require :input 'keyboard 'config)


;;------------------------------------------------------------------------------
;; Configuration
;;------------------------------------------------------------------------------

(keyboard:layout:config :full :qwerty)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard '+layouts '+qwerty 'config)
