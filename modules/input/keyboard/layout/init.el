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
          :path     "keyboard/layout"
          :filename "types/init")
(imp:load :feature  '(:input keyboard layout derive)
          :path     "keyboard/layout"
          :filename "derive")
(imp:load :feature  '(:input keyboard layout layout)
          :path     "keyboard/layout"
          :filename "layout")
(imp:load :feature  '(:input keyboard layout bind)
          :path     "keyboard/layout"
          :filename "bind")
(imp:load :feature  '(:input keyboard layout bind-debug)
          :path     "keyboard/layout"
          :filename "bind-debug")

;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard 'layout 'init)
