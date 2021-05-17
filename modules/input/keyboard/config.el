;;; input/keyboard/config.el -*- lexical-binding: t; -*-


;;                                  ──────────                                ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                            Keyboard Layouts                            ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                  ──────────                                ;;


;;------------------------------------------------------------------------------
;; Required
;;------------------------------------------------------------------------------

;; Order matters.
;;   - But there are none right now, so.


;;------------------------------------------------------------------------------
;; Optional
;;------------------------------------------------------------------------------

;; None at the moment.


;;------------------------------------------------------------------------------
;; Config: Keyboard Layouts
;;------------------------------------------------------------------------------

;;------------------------------
;; Qwerty
;;------------------------------
;; Always need qwerty (right now) for unmapping help.
(load! "layout/qwerty/config")
;; (input:keyboard/layout:load-if :qwerty "config")


;;------------------------------
;; Dvorak (Optional)
;;------------------------------
;; Normal Dvorak
(input:keyboard/layout:load-if :dvorak "config")

;; Dvorak with non-standard keybinds of mine.
(input:keyboard/layout:load-if :spydez "config")


;;------------------------------
;; <NEXT LAYOUT> (Optional)
;;------------------------------


;;------------------------------------------------------------------------------
;; Config: Set-Up Active Layout for Use
;;------------------------------------------------------------------------------

(input:keyboard/layout:configure-active)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------