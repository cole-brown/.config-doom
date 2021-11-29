;;; input/keyboard/layout/spydez/config.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                                 SpydeZ                                 ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                Dvorak Layout: Cuz I was bored in college...                ;;
;;             Non-standard Evil Layout: Cuz I'm weird that way.              ;;
;;                                 ──────────                                 ;;

;; Should be done with all the 'config' of ':input/keyboard'.
(imp:require :input 'keyboard 'config)


;;------------------------------------------------------------------------------
;; Configuration
;;------------------------------------------------------------------------------

(keyboard:layout:config :full :spydez)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard '+layouts '+spydez 'config)
