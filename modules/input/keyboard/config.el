;;; input/keyboard/config.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                            Keyboard Layouts                            ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                           Configure the Layouts.                           ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Configure Keyboard Layouts
;;------------------------------------------------------------------------------

;;------------------------------
;; Layout Builder
;;------------------------------
;; Nothing to do for 'config' step in code - just need to config the actual layout.


;;------------------------------
;; Config done; ready for layouts.
;;------------------------------
(imp:provide :input 'keyboard 'config)


;;------------------------------
;; Configure a Specific Layout?
;;------------------------------
(imp:load :feature  '(:input keyboard +layouts config)
          :path     "keyboard"
          :filename "+layouts/config")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard)
