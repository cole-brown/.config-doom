;;; input/keyboard/layout/init.el -*- lexical-binding: t; -*-


;;                                  ──────────                                ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                        Keyboard Layout Builders                        ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                  ──────────                                ;;


;;------------------------------------------------------------------------------
;; Layout Building Functions
;;------------------------------------------------------------------------------

;; Functions for both evil and emacs.
(load! "layout")

;; Only include evil if it's being used.
(when (featurep! :editor evil)
  (load! "evil"))

(load! "emacs")

;; TODO: Does doom have keybinds it does only when NOT evil? We'll need a file
;; for that in that case. Probably rename 'emacs' to 'common' or something and
;; then use 'emacs' for the non-evil binds.


;;------------------------------------------------------------------------------
;; Layout Inits
;;------------------------------------------------------------------------------

;; Currently being handled by init.el a level up.
;; TODO: Should we be in charge of calling the layouts' inits here instead?
;;   - And if so, make a config.el to be in charge of that aspect instead of the
;;     config.el a level up.
