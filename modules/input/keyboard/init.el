;; layout/keyboard/init.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                            Keyboard Layouts                            ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;             Not everyone uses Qwerty - there are dozens of us!             ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Doom Keybind Files
;;------------------------------------------------------------------------------
;;
;; Doom's `map!' macro and other keybinding functions:
;;   ~/.emacs.d/core/core-keybinds.el
;;
;; Doom's keybinds for evil mode:
;;   ~/.emacs.d/modules/config/default/+evil-bindings.el
;;
;; Some evil keybinds:
;;   ~/.emacs.d/modules/editor/evil/config.el
;;
;; Evil itself:
;;   ~/.emacs.d/.local/straight/repos/evil/evil-keybindings.el
;;   ~/.emacs.d/.local/straight/repos/evil/evil-maps.el


;;------------------------------------------------------------------------------
;; Load: Required Code Files
;;------------------------------------------------------------------------------

;; NOTE: Order could matter - take care if modifying.
(load! "command")
(load! "output")
(load! "utils")
(load! "alist")
(load! "debug")
(load! "vars")
(load! "load")
(load! "registrars")


;;------------------------------------------------------------------------------
;; Init: ':input/keyboard' Module
;;------------------------------------------------------------------------------

;;------------------------------
;; Error Checking & Setting of `int<keyboard>:layout:desired'
;;------------------------------

;; Should not have more than one keyboard layout, but only check when loading.
(int<keyboard>:load:if-allowed
    (:init)
  ;; We are loading, so check our module flags.
  (let ((flags (doom-module-get :input 'keyboard :flags))
        (layouts 0)
        (suppress-warning nil))
    (when (and (> 1
                  (dolist (flag flags layouts)
                    (when (eq flag '+suppress/layouts)
                      (setq suppress-warning t))
                    (when (string-prefix-p "+layout/" (symbol-name flag))
                      ;; Save first/only as desired layout.
                      (when (null int<keyboard>:layout:desired)
                        (setq int<keyboard>:layout:desired
                              (int<keyboard>:normalize->keyword flag))
                        ;; Count for a warning (if not suppressed).
                        (setq layouts (1+ layouts))))))
               ;; Warn only if we didn't see the suppression.
               (not suppress-warning))
      (warn (concat "Doom Module `:input/keyboard' init detected %d keyboard "
                    "layout flags. You should really only have one. Suppress "
                    "this by adding the `+suppress/layouts' flag. flags: %S")
            layouts
            flags))))


;;------------------------------------------------------------------------------
;; Init: Keyboard Layouts
;;------------------------------------------------------------------------------

;;------------------------------
;; Layout Builder and Specific Layouts' Inits
;;------------------------------
(load! "layout/init")


;;------------------------------------------------------------------------------
;; Just Before The End.
;;------------------------------------------------------------------------------
;; Clear out the `load:deny' flag...
(int<keyboard>:load:deny/clear)

;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard)
