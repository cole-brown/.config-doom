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

;;------------------------------
;; OLD: IJKL position keys (WASD left-hand, index on home key)
;;------------------------------
(input:keyboard/layout:set :spydez :evil
  ;; Keybinds for the `:spydez' layout: a big list of inputs to
  ;; `input:keyboard/layout:map!'.
  '(;; ╔════════════════════════════════════════════════════════════════╗
    ;; ║ Keymap: nil/global                                             ║
    ;; ╚════════════════════════════════════════════════════════════════╝

    ;; ┌────────────────────────────────┐
    ;; │ Movement                       │
    ;; └────────────────────────────────┘

    ;; ──┬────────────────
    ;;   │ ↑ ↓ ← →
    ;; ──┴────────────────
    :nvm  "c"  :layout:evil:line-prev
    :nvm  "t"  :layout:evil:line-next
    :nvm  "n"  :layout:evil:char-prev
    :nvm  "h"  :layout:evil:char-next))


(input:keyboard/layout:temp :spydez :evil
  ;; Keybinds for the `:spydez' layout: a big list of inputs to
  ;; `input:keyboard/layout:map!'.
  '(;; ╔════════════════════════════════════════════════════════════════╗
    ;; ║ Keymap: nil/global                                             ║
    ;; ╚════════════════════════════════════════════════════════════════╝

    ;; ┌────────────────────────────────┐
    ;; │ States                         │
    ;; └────────────────────────────────┘
    ;; IJKL position keys (WASD-style, right hand).
    (:prefix ("s" . "Evil States")
     :nv  "h"  :layout:evil:state-insert-before
     :nv  "n"  :layout:evil:state-insert-after
     :n   "t"  :layout:evil:state-insert-line-open-below
     :n   "c"  :layout:evil:state-insert-line-open-above

     ;; :n  (:derive 'shift :layout:evil:state-insert-before) :layout:evil:state-insert-line-start
     ;; :n  (:derive 'shift :layout:evil:state-insert-after)  :layout:evil:state-insert-line-end
     ;; :n  (:derive 'shift :layout:evil:state-insert-line-open-below)  :layout:evil:state-replace

     ;; TODO: Leave as Dvorak 'v'?
     :m  "v"  :layout:evil:state-visual-char-wise
     :m  "V"  :layout:evil:state-visual-line-wise)))


;;------------------------------
;; NEW: ESDF position keys (shifted-WASD left-hand, index on home key)
;;------------------------------
;; TODO: Why tripping on ':prefix'?
(ignore 'input:keyboard/layout:set :spydez :evil
  ;; Keybinds for the `:spydez' layout: a big list of inputs to
  ;; `input:keyboard/layout:map!'.
  '(;; ╔════════════════════════════════════════════════════════════════╗
    ;; ║ Keymap: nil/global                                             ║
    ;; ╚════════════════════════════════════════════════════════════════╝

    ;; ┌────────────────────────────────┐
    ;; │ States                         │
    ;; └────────────────────────────────┘
    ;; IJKL position keys (WASD-style, right hand).
    (:prefix ("s" . "Evil States")
     :nv  "h"  :state:insert:before
     :nv  "n"  :state:insert:after
     :n   "t"  :state:insert:line:open-below
     :n   "c"  :state:insert:line:open-above

     ;; :n  (:derive 'shift :state:insert:before) :state:insert:line:start
     ;; :n  (:derive 'shift :state:insert:after)  :state:insert:line:end
     ;; :n  (:derive 'shift :state:insert:line:open-below)  :state:replace

     ;; TODO: Leave as Dvorak 'v'?
     :m  "v"  :state:visual:char-wise
     :m  "V"  :state:visual:line-wise)


    ;; ┌────────────────────────────────┐
    ;; │ Movement                       │
    ;; └────────────────────────────────┘

    ;; ──┬────────────────
    ;;   │ ↑ ↓ ← →
    ;; ──┴────────────────
    ;; ESDF position keys (WASD shifted rightward one for index on home key).
    :nvm  "."  :layout:evil:line-prev
    :nvm  "e"  :layout:evil:line-next
    :nvm  "o"  :layout:evil:char-prev
    :nvm  "u"  :layout:evil:char-next
    ))

(ignore '(
    ;; ;; ──┬────────────────
    ;; ;;   │ Word
    ;; ;; ──┴────────────────
    ;; ;; ESDF-based. To go 'farther away', move finger away (e.g. word-next-begin is "U", word-next-end is "I".)
    ;; ;; "Small" words: Shift
    ;; ;; "Big"   words: Control
    ;; :m  "U"    :layout:evil:word-next-begin
    ;; :m  "I"    :layout:evil:word-next-end
    ;; :m  "A"    :layout:evil:word-prev-begin
    ;; :m  "O"    :layout:evil:word-prev-end
    ;; :m  "C-u"  :layout:evil:word-next-begin-bigword ;; aka :layout:evil:word-next with optional arg BIGWORD set to 't'
    ;; :m  "C-i"  :layout:evil:word-next-end-bigword
    ;; :m  "C-a"  :layout:evil:word-prev-begin-bigword
    ;; :m  "C-o"  :layout:evil:word-prev-end-bigword

    ;; ;; ──┬────────────────
    ;; ;;   │ Sentences
    ;; ;; ──┴────────────────
    ;; ;; TODO: Leave as-is or move near movement keys?
    ;; :m  "("  :layout:evil:sentence-begin-prev
    ;; :m  ")"  :layout:evil:sentence-begin-next

    ;; ;; ──┬────────────────
    ;; ;;   │ Paragraphs
    ;; ;; ──┴────────────────
    ;; ;; TODO: Leave as-is or move near movement keys?
    ;; :m  "{"  :layout:evil:paragraph-prev
    ;; :m  "}"  :layout:evil:paragraph-next


    ;; ;; ──┬────────────────
    ;; ;;   │ Scroll
    ;; ;; ──┴────────────────
    ;; ;; Recentering.
    ;; (:prefix (";" . "Movement...")  ;; prefix for even more movement commands
    ;;  :m (:derive :layout:evil:line-prev)                :layout:evil:scroll-line-to-top
    ;;  :m (:derive 'prefix)                               :layout:evil:scroll-line-to-center
    ;;  :m (:derive :layout:evil:line-next)                :layout:evil:scroll-line-to-bottom
    ;;  :m (:derive 'shift :layout:evil:line-prev)         :layout:evil:scroll-top-line-to-bottom
    ;;  :m (:derive 'shift :layout:evil:line-next)         :layout:evil:scroll-bottom-line-to-top)
    ;; ;; Half page scrolling.
    ;; :m (:derive 'control :layout:evil:line-prev)        :layout:evil:scroll-up
    ;; :m (:derive 'control :layout:evil:line-next)        :layout:evil:scroll-down
    ;; :m (:derive 'control :layout:evil:char-prev)        :layout:evil:scroll-left
    ;; :m (:derive 'control :layout:evil:char-next)        :layout:evil:scroll-right
    ;; ;; Full page scrolling.
    ;; :m (:derive 'control 'alt :layout:evil:line-prev)   :layout:evil:scroll-page-up
    ;; :m (:derive 'control 'alt :layout:evil:line-next)   :layout:evil:scroll-page-down
    ;; ;; Line/column scrolling.
    ;; :m (:derive 'control 'shift :layout:evil:line-prev) :layout:evil:scroll-line-up
    ;; :m (:derive 'control 'shift :layout:evil:line-next) :layout:evil:scroll-line-down
    ;; :m (:derive 'control 'shift :layout:evil:char-prev) :layout:evil:scroll-column-left
    ;; :m (:derive 'control 'shift :layout:evil:char-next) :layout:evil:scroll-column-right
    ;; ;; Unused:
    ;; ;; :? "" :layout:evil:scroll-count-reset

    ;;------------------------------
    ;; TODO: Check/change keys:
    ;;------------------------------

    ;; ;; ──┬────────────────
    ;; ;;   │ Lines
    ;; ;; ──┴────────────────
    ;; ;; ',py
    ;; ;; qjk
    ;; :m  "TAB"  :layout:evil:item-jump ;; Was %, and also in some modes tab in some way that doesn't show under help's keybinds for tab...
    ;; :m  "0"    :layout:evil:digit-arg-0/line-start
    ;; :m  "C-a"  :layout:evil:line-begin
    ;; :m  "$"    :layout:evil:line-end
    ;; :m  "-"    :layout:evil:line-prev-first-non-blank
    ;; :m  "^"    :layout:evil:line-current-first-non-blank
    ;; :m  "_"    :layout:evil:line-next-1-first-non-blank
    ;; :m  "+"    :layout:evil:line-next-first-non-blank

    ;; :m  "G"  :layout:evil:goto-line-first-non-blank ;; default:layout:evil: last line in buffer
    ;; :m  "H"  :layout:evil:goto-line-visible-first
    ;; :m  "M"  :layout:evil:goto-line-visible-middle
    ;; :m  "L"  :layout:evil:goto-line-visible-last
    ))


;; TODO: These and more


;; ;; ──┬────────────────
;; ;;   │ Searches
;; ;; ──┴────────────────
;; ;; evil: motion
;; :m  "n"  :layout:evil:search-next
;; :m  "N"  :layout:evil:search-prev
;; :m  "/"  :layout:evil:search-forward
;; :m  "?"  :layout:evil:search-backward

;; :m  "#"  :layout:evil:search-word-backward
;; :m  "*"  :layout:evil:search-word-forward

;; :m  "t"  :layout:evil:snipe-next-1-t ;; TODO: not a keyboard-dependent keyword?
;; :m  "f"  :layout:evil:snipe-next-1-f ;; TODO: not a keyboard-dependent keyword?
;; :m  "T"  :layout:evil:snipe-prev-1-T ;; TODO: not a keyboard-dependent keyword?
;; :m  "F"  :layout:evil:snipe-prev-1-F ;; TODO: not a keyboard-dependent keyword?
;; :m  "s"  :layout:evil:snipe-next-2-s ;; TODO: not a keyboard-dependent keyword?
;; :m  "S"  :layout:evil:snipe-prev-2-S ;; TODO: not a keyboard-dependent keyword?
;; :m  ";"  :layout:evil:snipe-repeat
;; :m  ","  :layout:evil:snipe-repeat-inverse

;; ;; ──┬────────────────
;; ;;   │ Marks
;; ;; ──┴────────────────
;; :n  "m"  :layout:evil:mark-set
;; :m  "`"  :layout:evil:mark-goto


;; ┌────────────────────────────────┐
;; │ Next Thing                     │
;; └────────────────────────────────┘

;; TODO: Many more keybinds for global?
;; TODO: Many more keymaps


;;------------------------------------------------------------------------------
;; Emacs
;;------------------------------------------------------------------------------

;; None right now.


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
