;;; input/keyboard/layout/spydez/init.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                                 SpydeZ                                 ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                Dvorak Layout: Cuz I was bored in college...                ;;
;;             Non-standard Evil Layout: Cuz I'm weird that way.              ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Common
;;------------------------------------------------------------------------------

;; None right now.


;;------------------------------------------------------------------------------
;; Evil
;;------------------------------------------------------------------------------

;; Set `:spydez' as the active layout, and also set our evil keybinds.
;; Does not configure the keybinds; just saves it for now.
(input:keyboard/layout:set :spydez :evil
  ;; Keybinds for the `:spydez' layout: a big list of inputs to
  ;; `input:keyboard/layout:map!'.
  '(;; ╔════════════════════════════════════════════════════════════════╗
    ;; ║ Keymap: nil/global                                             ║
    ;; ╚════════════════════════════════════════════════════════════════╝

    ;; ┌────────────────────────────────┐
    ;; │ Movement                       │
    ;; └────────────────────────────────┘

    :nvm  "c"  :layout:evil:line-prev
    :nvm  "t"  :layout:evil:line-next
    :nvm  "h"  :layout:evil:char-next
    :nvm  "n"  :layout:evil:char-prev

    ;; TODO: Many more keybinds for global?
    ;; TODO: Many more keymaps
    ))


;;------------------------------------------------------------------------------
;; Emacs
;;------------------------------------------------------------------------------

;; None right now.


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
