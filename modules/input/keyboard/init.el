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

(imp:path:root :input
               (imp:path:join doom-private-dir
                              "modules"
                              "input")
               "init.el")


;; NOTE: Order could matter - take care if modifying.
(imp:load :feature  '(:input keyboard command)
          :path     "keyboard"
          :filename "command")
(imp:load :feature  '(:input keyboard output)
          :path     "keyboard"
          :filename "output")
(imp:load :feature  '(:input keyboard utils)
          :path     "keyboard"
          :filename "utils")
(imp:load :feature  '(:input keyboard alist)
          :path     "keyboard"
          :filename "alist")
(imp:load :feature  '(:input keyboard debug)
          :path     "keyboard"
          :filename "debug")
(imp:load :feature  '(:input keyboard vars)
          :path     "keyboard"
          :filename "vars")
(imp:load :feature  '(:input keyboard load)
          :path     "keyboard"
          :filename "load")
(imp:load :feature  '(:input keyboard registrars)
          :path     "keyboard"
          :filename "registrars")


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
;; Layout Builder
;;------------------------------
(imp:load :feature  '(:input keyboard layout init)
          :path     "keyboard"
          :filename "layout/init")


;;------------------------------
;; Init done; ready for layouts.
;;------------------------------
(imp:provide :input 'keyboard 'init)


;;------------------------------
;; Init a Specific Layout?
;;------------------------------
(imp:load :feature  '(:input keyboard +layouts init)
          :path     "keyboard"
          :filename "+layouts/init")


;;------------------------------------------------------------------------------
;; Just Before The End.
;;------------------------------------------------------------------------------
;; Clear out the `load:deny' flag...
(int<keyboard>:load:deny/clear)

;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
;; No additional `imp:provide' for this file; already provided it, above.
