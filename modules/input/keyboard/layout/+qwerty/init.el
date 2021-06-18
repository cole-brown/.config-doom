;;; input/keyboard/layout/qwerty/init.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                                 Qwerty                                 ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;       Typewriters needed to be slow, so let's just stick with that.        ;;
;;                                 ──────────                                 ;;

;;------------------------------------------------------------------------------
;; Common
;;------------------------------------------------------------------------------

;; None right now.


;;------------------------------------------------------------------------------
;; Evil
;;------------------------------------------------------------------------------

;; Set our evil keybinds. Does not configure the keybinds; just saves it for now.
(input:keyboard/layout:set :qwerty :evil
  ;; Keybinds for the `:qwerty' layout: a big list of inputs to
  ;; `input:keyboard/layout:map!'.
  '(;; ╔════════════════════════════════════════════════════════════════╗
    ;; ║ Keymap: nil/global                                             ║
    ;; ╚════════════════════════════════════════════════════════════════╝

    ;; ┌────────────────────────────────┐
    ;; │ States                         │
    ;; └────────────────────────────────┘
    :n  "i"  :state:insert:before
    :v  "I"  :state:insert:before

    :n  "a"  :state:insert:after
    :v  "A"  :state:insert:after

    :n  "o"  :state:insert:line:open-below
    :n  "O"  :state:insert:line:open-above

    :n  "I"  :state:insert:line:start
    :n  "A"  :state:insert:line:end
    :n  "R"  :state:replace

    :m  "v"  :state:visual:char-wise
    :m  "V"  :state:visual:line-wise


    ;; ┌────────────────────────────────┐
    ;; │ Movement                       │
    ;; └────────────────────────────────┘

    ;; ──┬────────────────
    ;;   │ ↑ ↓ ← →
    ;; ──┴────────────────
    ;;  evil: normal, visual, motion
    :nvm  "k"  :layout:evil:line-prev
    :nvm  "j"  :layout:evil:line-next
    :nvm  "l"  :layout:evil:char-next
    :nvm  "h"  :layout:evil:char-prev

    ;; ──┬────────────────
    ;;   │ Word
    ;; ──┴────────────────
    ;; evil: motion
    :m  "w"  :layout:evil:word-next-begin
    :m  "e"  :layout:evil:word-next-end
    :m  "b"  :layout:evil:word-prev-begin
    ;; :m  ___  :layout:evil:word-prev-end
    :m  "W"  :layout:evil:word-next-begin-bigword ;; aka :layout:evil:word-next with optional arg BIGWORD set to 't'
    :m  "E"  :layout:evil:word-next-end-bigword
    :m  "B"  :layout:evil:word-prev-begin-bigword
    ;; :m  ___  :layout:evil:word-prev-end-bigword

    ;; ──┬────────────────
    ;;   │ Sentences
    ;; ──┴────────────────
    ;; evil: motion
    :m  "("  :layout:evil:sentence-begin-prev
    :m  ")"  :layout:evil:sentence-begin-next

    ;; ──┬────────────────
    ;;   │ Paragraphs
    ;; ──┴────────────────
    ;; evil: motion
    :m  "{"  :layout:evil:paragraph-prev
    :m  "}"  :layout:evil:paragraph-next

    ;; ──┬────────────────
    ;;   │ Lines
    ;; ──┴────────────────
    ;; evil: motion
    :m  "%"  :layout:evil:item-jump
    :m  "0"  :layout:evil:digit-arg-0/line-start
    :m  "$"  :layout:evil:line-end
    :m  "-"  :layout:evil:line-prev-first-non-blank
    :m  "^"  :layout:evil:line-current-first-non-blank
    :m  "_"  :layout:evil:line-next-1-first-non-blank
    :m  "+"  :layout:evil:line-next-first-non-blank

    ;; evil: motion
    :m  "G"  :layout:evil:goto-line-first-non-blank ;; default:layout:evil: last line in buffer
    :m  "H"  :layout:evil:goto-line-visible-first
    :m  "M"  :layout:evil:goto-line-visible-middle
    :m  "L"  :layout:evil:goto-line-visible-last

    ;; ──┬────────────────
    ;;   │ Scroll
    ;; ──┴────────────────
    ;; evil: motion
    :m "C-u" :layout:evil:scroll-up
    :m "C-d" :layout:evil:scroll-down
    :m "zH"  :layout:evil:scroll-left  ;; Related to main motion keys
    :m "zL"  :layout:evil:scroll-right ;; Related to main motion keys
    :m "zt"  :layout:evil:scroll-line-to-top
    :m "zz"  :layout:evil:scroll-line-to-center
    :m "zb"  :layout:evil:scroll-line-to-bottom
    :m "C-b" :layout:evil:scroll-page-up
    :m "C-f" :layout:evil:scroll-page-down
    :m "C-y" :layout:evil:scroll-line-up
    :m "C-e" :layout:evil:scroll-line-down
    :m "zh"  :layout:evil:scroll-column-left  ;; Related to main motion keys
    :m "zl"  :layout:evil:scroll-column-right ;; Related to main motion keys
    :m "z^"  :layout:evil:scroll-top-line-to-bottom
    :m "z+"  :layout:evil:scroll-bottom-line-to-top
    ;; Unused:
    ;; :? "" :layout:evil:scroll-count-reset

    ;; ──┬────────────────
    ;;   │ Searches
    ;; ──┴────────────────
    ;; evil: motion
    :m  "n"  :layout:evil:search-next
    :m  "N"  :layout:evil:search-prev
    :m  "/"  :layout:evil:search-forward
    :m  "?"  :layout:evil:search-backward

    :m  "#"  :layout:evil:search-word-backward
    :m  "*"  :layout:evil:search-word-forward

    :m  "t"  :layout:evil:snipe-next-1-t ;; TODO: not a keyboard-dependent keyword?
    :m  "f"  :layout:evil:snipe-next-1-f ;; TODO: not a keyboard-dependent keyword?
    :m  "T"  :layout:evil:snipe-prev-1-T ;; TODO: not a keyboard-dependent keyword?
    :m  "F"  :layout:evil:snipe-prev-1-F ;; TODO: not a keyboard-dependent keyword?
    :m  "s"  :layout:evil:snipe-next-2-s ;; TODO: not a keyboard-dependent keyword?
    :m  "S"  :layout:evil:snipe-prev-2-S ;; TODO: not a keyboard-dependent keyword?
    :m  ";"  :layout:evil:snipe-repeat
    :m  ","  :layout:evil:snipe-repeat-inverse

    ;; ──┬────────────────
    ;;   │ Marks
    ;; ──┴────────────────
    ;; evil: normal
    :n  "m"  :layout:evil:mark-set
    ;; evil: motion
    :m  "`"  :layout:evil:mark-goto

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


;; TODO: steal all these key strings to flesh out the qwerty layout

;; ;;------------------------------------------------------------------------------
;; ;; Constants & Variables
;; ;;------------------------------------------------------------------------------

;; (defvar input//kl:qwerty:keys
;;   '(;;-------------------------------------------------------------------------
;;     ;; Global Keymap
;;     ;;-------------------------------------------------------------------------
;;     (nil .
;;          (;;------------------------------
;;           ;; Movement
;;           ;;------------------------------
;;           ;;---
;;           ;; Up/Down/Left/Right
;;           ;;---
;;           (:line:prev                     . "k")
;;           (:line:next                     . "j")
;;           (:char:next                     . "h")
;;           (:char:prev                     . "l")


;;           ;;------------------------------
;;           ;; Repeating
;;           ;;------------------------------
;;           (:digit-arg:1                   . "1")
;;           (:digit-arg:2                   . "2")
;;           (:digit-arg:3                   . "3")
;;           (:digit-arg:4                   . "4")
;;           (:digit-arg:5                   . "5")
;;           (:digit-arg:6                   . "6")
;;           (:digit-arg:7                   . "7")
;;           (:digit-arg:8                   . "8")
;;           (:digit-arg:9                   . "9")
;;           ;; (:digit-arg:0/line:start     . "0")


;;           ;;------------------------------
;;           ;; Text Maniplutaion
;;           ;;------------------------------

;;           ;;---
;;           ;; Undo/Redo
;;           ;;---
;;           (:text:undo                     . "u")
;;           (when (featurep! :emacs undo)
;;             (:text:redo                   . "r"))

;;           ;;---
;;           ;; Copy/Cut/Paste
;;           ;;---
;;           (:kill-ring:copy                . "y")
;;           (:kill-ring:copy:line           . "Y")
;;           (:text:delete:line:point-to-end . "D")
;;           (:text:delete                   . "d")
;;           (:paste:after                   . "p")
;;           (:paste:before                  . "P")
;;           (:char:delete:current           . "x")
;;           (:char:delete:prev              . "X")

;;           ;; "Change" meaning "delete and put me in insert mode"?
;;           (:change:dwim                   . "c")
;;           (:change:line:point-to-end      . "C")

;;           ;;---
;;           ;; Indent/Outdent
;;           ;;---
;;           (:text:shift:left               . "<")
;;           (:text:shift:right              . ">")
;;           (:indent                        . "=")

;;           (:case:invert                   . "~")
;;           (:replace:repeat                . "&")  ;; Same as: :s//~/
;;           (when (not (featurep! :emacs undo))
;;             (:char:replace                . "r"))

;;           ;;---
;;           ;; Line-Based
;;           ;;---
;;           (:line:join:next-to-current     . "J")

;;           ;;---
;;           ;; Macros (not Emacs macros)
;;           ;;---
;;           (:macro:record                  . "q")
;;           (:macro:execute                 . "@")

;;           ;;---
;;           ;; Repeat "the last editing command".
;;           ;;---
;;           (:edit:repeat                   . ".")

;;           ;;------------------------------
;;           ;; Commands
;;           ;;------------------------------
;;           ;;---
;;           ;; Evil Command
;;           ;;---
;;           (:evil:command                  . ":")

;;           ;;---
;;           ;; Shell Command
;;           ;;---
;;           (:shell:command                 . "!")  ;; Execute region as shell command?

;;           ;;------------------------------
;;           ;; Misc.
;;           ;;------------------------------
;;           (:docs:lookup                   . "K")


;;           ;;------------------------------
;;           ;; No Keybind
;;           ;;------------------------------
;;           (:undefined                     . "Q")
;;           (:undefined                     . "U")


;;           ;;------------------------------
;;           ;; TODO: All the multi-key keybinds
;;           ;;------------------------------
;;           ;; These aren't keybinds - they just have a lot of keybinds in them.
;;           ;; (:menu:prev  . "[")
;;           ;; (:menu:next  . "]")
;;           ;; (:menu:text? . "g")
;;           ;; (:menu:???   . "z")
;;           ;; (:menu:???   . "Z")


;;           ;;------------------------------
;;           ;; TODO: All the modifier keybinds (Ctrl, Shift, etc)
;;           ;;------------------------------
;;           ;; like, do everything all over again but with Ctrl.
;;           ;; ...and then shift...
;;           ;; ...and then etc...
;;           ))


;;     ;;--------------------------------------------------------------------------
;;     ;; TODO: A bunch of other mode maps.
;;     ;;--------------------------------------------------------------------------
;;     )
;;   "Keyword -> kbd string alist for the active/desired keyboard layout.")


;; (defvar input//kl:qwerty:functions
;;   '(;;--------------------------------------------------------------------------
;;     ;; Global Keymap
;;     ;;--------------------------------------------------------------------------
;;     (nil .
;;          (;;------------------------------
;;           ;; Movement
;;           ;;------------------------------
;;           (:up    . #'evil-previous-line)
;;           (:down  . #'evil-next-line)
;;           (:left  . #'evil-backward-char)
;;           (:right . #'evil-forward-char)

;;           ;; TODO: updated to input//kl:qwerty:keys

;;           )))
;;   "Keymap -> Keyword -> function alists for the active/desired keyboard
;; layout.")

;; (defvar input//kl:qwerty:functions-2
;;   '(;;-------------------------------------------------------------------------
;;     ;; Global Keymap
;;     ;;-------------------------------------------------------------------------
;;     (nil .
;;          (;;------------------------------
;;           ;; Movement
;;           ;;------------------------------
;;           ;;---
;;           ;; Up/Down/Left/Right
;;           ;;---
;;           (:line:prev                     . #'evil-previous-line)
;;           (:line:next                     . #'evil-next-line)
;;           (:char:next                     . #'evil-backward-char)
;;           (:char:prev                     . #'evil-forward-char)

;;           ;;---
;;           ;; Word
;;           ;;---
;;           (:word:next:begin               . #'evil-forward-word-begin)
;;           (:word:next:end                 . #'evil-forward-word-end)
;;           (:word:prev:begin               . #'evil-backward-word-begin)
;;           (:word:next:begin:bigword       . #'evil-forward-WORD-begin)
;;           (:word:next:end:bigword         . #'evil-forward-WORD-end)
;;           (:word:prev:begin:bigword       . #'evil-backward-WORD-begin)

;;           ;;---
;;           ;; Sentences
;;           ;;---
;;           (:sentence:begin:prev           . #'evil-backward-sentence-begin)
;;           (:sentence:begin:next           . #'evil-forward-sentence-begin)

;;           ;;---
;;           ;; Paragraphs
;;           ;;---
;;           (:paragraph:prev                . #'evil-backward-paragraph)
;;           (:paragraph:next                . #'evil-forward-paragraph)

;;           ;;---
;;           ;; Lines
;;           ;;---
;;           (:item:jump                     . #'evil-jump-item)
;;           (:digit-arg:0/line:start        . #'evil-digit-argument-or-evil-beginning-of-line)
;;           (:line:end                      . #'evil-end-of-line)
;;           (:line:prev:first-non-blank     . #'evil-previous-line-first-non-blank)
;;           (:line:current:first-non-blank  . #'evil-first-non-blank)
;;           (:line:next-1:first-non-blank   . #'evil-next-line-1-first-non-blank)
;;           (:line:next:first-non-blank     . #'evil-next-line-first-non-blank)

;;           ;;---
;;           ;; Go-To Line
;;           ;;---
;;           (:goto:line:first-non-blank     . #'evil-goto-line) ;; default: last line in buffer
;;           (:goto:line:visible:first       . #'evil-window-top)
;;           (:goto:line:visible:middle      . #'evil-window-middle)
;;           (:goto:line:visible:last        . #'evil-window-bottom)

;;           ;;---
;;           ;; Searches
;;           ;;---
;;           (:search:next                   . #'evil-ex-search-next) ; TODO: double check w/ qwerty bindings on. "n"
;;           (:search:prev                   . #'evil-ex-search-previous)
;;           (:search:forward                . #'evil-ex-search-forward)
;;           (:search:backward               . #'evil-ex-search-backward)

;;           (:search:word:backward          . #'evil-ex-search-word-backward)
;;           (:search:word:forward           . #'evil-ex-search-word-forward)

;;           ;; TODO: snipe seems very tied to its keys that it has hard-coded...
;;           ;; May need to use `evil-snipe-def' to invent new ones...
;;           (:snipe:next:1-t                . #'evil-snipe-t)
;;           (:snipe:next:1-f                . #'evil-snipe-f)
;;           (:snipe:prev:1-t                . #'evil-snipe-T)
;;           (:snipe:prev:1-f                . #'evil-snipe-F)
;;           (:snipe:next:2                  . #'evil-snipe-s)
;;           (:snipe:prev:2                  . #'evil-snipe-S)
;;           (:snipe:repeat                  . #'evil-snipe-repeat)
;;           (:snipe:repeat:inverse          . #'evil-snipe-repeat-reverse)

;;           ;;---
;;           ;; Marks
;;           ;;---
;;           (:mark:set                      . #'evil-set-marker)
;;           (:mark:goto                     . #'evil-goto-mark)


;;           ;;------------------------------
;;           ;; Repeating
;;           ;;------------------------------
;;           (:digit-arg:1                   . #'digit-argument)
;;           (:digit-arg:2                   . #'digit-argument)
;;           (:digit-arg:3                   . #'digit-argument)
;;           (:digit-arg:4                   . #'digit-argument)
;;           (:digit-arg:5                   . #'digit-argument)
;;           (:digit-arg:6                   . #'digit-argument)
;;           (:digit-arg:7                   . #'digit-argument)
;;           (:digit-arg:8                   . #'digit-argument)
;;           (:digit-arg:9                   . #'digit-argument)
;;           ;; (:digit-arg:0/line:start     . #'evil-digit-argument-or-evil-beginning-of-line)


;;           ;;------------------------------
;;           ;; Text Maniplutaion
;;           ;;------------------------------

;;           ;;---
;;           ;; Undo/Redo
;;           ;;---
;;           (:text:undo                     . #'evil-undo)
;;           (when (featurep! :emacs undo)
;;             (:text:redo                   . #'evil-redo))

;;           ;;---
;;           ;; Copy/Cut/Paste
;;           ;;---
;;           (:kill-ring:copy                . #'evil-yank)
;;           (:kill-ring:copy:line           . #'evil-yank-line)
;;           (:text:delete                   . #'evil-delete)
;;           (:text:delete:line:point-to-end . #'evil-delete-line)
;;           (:paste:after                   . #'evil-paste-after)
;;           (:paste:before                  . #'evil-paste-before)
;;           (:char:delete:current           . #'evil-delete-char)
;;           (:char:delete:prev              . #'evil-delete-backward-char)

;;           ;; "Change" meaning "delete and put me in insert mode"?
;;           (:change:dwim                   . #'evil-change) ; TODO: double check w/ qwerty bindings on. "c")
;;           (:change:line:point-to-end      . #'evil-change-line)

;;           ;;---
;;           ;; Indent/Outdent
;;           ;;---
;;           (:text:shift:left               . #'evil-shift-left)
;;           (:text:shift:right              . #'evil-shift-right)
;;           (:indent                        . #'evil-indent)

;;           (:case:invert                   . #'evil-invert-char)
;;           (:replace:repeat                . #'evil-ex-repeat-substitute)  ;; Same as: :s//~/
;;           (when (not (featurep! :emacs undo))
;;             (:char:replace                . #'evil-replace))

;;           ;;---
;;           ;; Line-Based
;;           ;;---
;;           (:line:join:next-to-current     . #'evil-join)

;;           ;;---
;;           ;; Macros (not Emacs macros)
;;           ;;---
;;           (:macro:record                  . #'evil-record-macro)
;;           (:macro:execute                 . #'evil-execute-macro)

;;           ;;---
;;           ;; Repeat "the last editing command".
;;           ;;---
;;           (:edit:repeat                   . #'evil-repeat)

;;           ;;------------------------------
;;           ;; Commands
;;           ;;------------------------------
;;           ;;---
;;           ;; Evil Command
;;           ;;---
;;           (:evil:command                  . #'evil-ex)

;;           ;;---
;;           ;; Shell Command
;;           ;;---
;;           (:shell:command                 . #'evil-shell-command)  ;; Execute region as shell command?

;;           ;;------------------------------
;;           ;; Evil States
;;           ;;------------------------------
;;           (:state:insert:before           . #'evil-insert)
;;           (:state:insert:after            . #'evil-append)
;;           (:state:insert:line:start       . #'evil-insert-line)
;;           (:state:insert:line:end         . #'evil-append-line)
;;           (:state:insert:line:open-below  . #'evil-open-below)
;;           (:state:insert:line:open-above  . #'evil-open-above)
;;           (:state:replace                 . #'evil-replace-state)
;;           (:state:visual:char-wise        . #'evil-visual-char)
;;           (:state:visual:line-wise        . #'evil-visual-line)


;;           ;;------------------------------
;;           ;; Doom!
;;           ;;------------------------------
;;           (:docs:lookup                   . #'+lookup/documentation)


;;           ;;------------------------------
;;           ;; No Keybind
;;           ;;------------------------------
;;           (:undefined                     . nil)
;;           (:undefined                     . nil)


;;           ;;------------------------------
;;           ;; TODO: All the multi-key keybinds
;;           ;;------------------------------
;;           ;; These aren't keybinds - they just have a lot of keybinds in them.
;;           ;; (:menu:prev  . #'"[")
;;           ;; (:menu:next  . #'"]")
;;           ;; (:menu:text? . #'"g")
;;           ;; (:menu:???   . #'"z")
;;           ;; (:menu:???   . #'"Z")


;;           ;;------------------------------
;;           ;; TODO: All the modifier keybinds (Ctrl, Shift, etc)
;;           ;;------------------------------
;;           ;; like, do everything all over again but with Ctrl.
;;           ;; ...and then shift...
;;           ;; ...and then etc...
;;           ))


;;     ;;--------------------------------------------------------------------------
;;     ;; TODO: A bunch of other mode maps.
;;     ;;--------------------------------------------------------------------------
;;     )
;;   "Keymap -> Keyword -> function alists for the active/desired keyboard
;; layout.")
