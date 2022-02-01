;;; input/keyboard/layout/types/init.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                Build & Initialize the Keyboard Layout.                 ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                        Only for the desired layout.                        ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Layout Type Functions
;;------------------------------------------------------------------------------

(imp:load :feature  '(:input keyboard layout types define)
          :filename "define")


;;------------------------------------------------------------------------------
;; Layout Types (:common, :emacs, :evil)
;;------------------------------------------------------------------------------

;;------------------------------
;; Layout Keyword -> Functions
;;------------------------------

;; Always include the common ones.
(imp:load :feature  '(:input keyboard layout types common)
          :filename "common")

;; Include either evil or emacs keybinds, depending on if evil-mode is being used.
(if (featurep! :editor evil)
    (imp:load :feature  '(:input keyboard layout types evil)
              :filename "evil")
  (imp:load :feature  '(:input keyboard layout types emacs)
            :filename "emacs"))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard 'layout 'types)
