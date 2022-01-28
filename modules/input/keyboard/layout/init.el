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

(imp:load :feature  '(:input keyboard layout types)
          :filename "types/init")
(imp:load :feature  '(:input keyboard layout derive)
          :filename "derive")
(imp:load :feature  '(:input keyboard layout layout)
          :filename "layout")
(imp:load :feature  '(:input keyboard layout bind)
          :filename "bind")
(imp:load :feature  '(:input keyboard layout bind-debug)
          :filename "bind-debug")

;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard 'layout 'init)
