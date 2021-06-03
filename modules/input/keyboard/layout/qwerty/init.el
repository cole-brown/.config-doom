;;; input/keyboard/layout/qwerty/init.el -*- lexical-binding: t; -*-


;;                                  ──────────                                ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                        :qwerty Layout Keybinds                         ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                  ──────────                                ;;


;;------------------------------------------------------------------------------
;; Common
;;------------------------------------------------------------------------------

;; None right now.


;;------------------------------------------------------------------------------
;; Evil
;;------------------------------------------------------------------------------

;; Set our evil keybinds. Does not configure the keybinds; just saves it for now.
(input:keyboard/layout:set :evil
  ;; Keybinds for the `:qwerty' layout: a big list of inputs to
  ;; `input:keyboard/layout:map!'.
  '(;; ╔════════════════════════════════════════════════════════════════╗
    ;; ║ Keymap: nil/global                                             ║
    ;; ╚════════════════════════════════════════════════════════════════╝

    ;; ┌────────────────────────────────┐
    ;; │ Movement                       │
    ;; └────────────────────────────────┘

    :nvm  "k"  :layout:evil:line-prev
    :nvm  "j"  :layout:evil:line-next
    :nvm  "l"  :layout:evil:char-next
    :nvm  "h"  :layout:evil:char-prev

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




;; ;;------------------------------------------------------------------------------
;; ;; Keyword Naming
;; ;;------------------------------------------------------------------------------
;; ;;
;; ;; - Try to be succinct; use short synonymns.
;; ;;   + Instead of 'beginning', use 'start'.
;; ;; - Try to modify the function name into a symbol based on these guidelines
;; ;;   (as opposed to just making up something that feels better).
;; ;;   + `beginning-of-line' -> `:line:start' as opposed to, say, `:point:bol'.
;; ;; - Try to use words instead of acronyms.
;; ;;   + E.g. "file end" or "end of file" instead of "eof" should be what you try
;; ;;     to make your symbol out of.
;; ;; - Be specific:
;; ;;   + `evil-previous-line-first-non-blank'
;; ;;     - YES: `:line:prev-non-blank'
;; ;;     -  NO: `:line:prev'
;; ;;     - Someone may want to use `evil-previous-line' everywhere instead of
;; ;;       `evil-previous-line-first-non-blank' and they should be the ones to
;; ;;       claim `:line:prev'.
;; ;;
;; ;;------------------------------
;; ;; Groupings:
;; ;;---
;; ;;   - If a key has a general grouping and a specific functionality in that
;; ;;     group of commands, order general->specific and separate with colons.
;; ;;     + :group-1:func-A
;; ;;     + :group-1:func-B
;; ;;     + :line:next
;; ;;     + :line:prev
;; ;;     + :line:prev-non-blank
;; ;;
;; ;;
;; ;;------------------------------
;; ;; Combos / Multi-Function:
;; ;;---
;; ;;   - If a key has multiple functionalities, depending on context, separate
;; ;;     them with a '/' character.
;; ;;     + :func-A/func-B
;; ;;   - If a key has different functionalities, depending on setup, use separate
;; ;;     `when's instead of a single `if' block so they can be place properly.
;; ;;     + YES:
;; ;;          <some section>
;; ;;          (when (featurep! :emacs undo)
;; ;;            (:undo:redo . "r"))
;; ;;          ...
;; ;;          <some other section>
;; ;;          (when (not (featurep! :emacs undo))
;; ;;            (:char:replace . "r"))
;; ;;     + NO:
;; ;;          (if (featurep! :emacs undo)
;; ;;              (:undo:redo . "r")
;; ;;            (:char:replace . "r"))
;; ;;
;; ;;
;; ;;------------------------------
;; ;; Combining:
;; ;;---
;; ;;   - Do the best you can, but you may not always be able to follow the
;; ;;     guidelines completely if in some hybrid of two or more things.
;; ;;   - E.g.: a grouping and a combo:
;; ;;     + :func-A/group-1:func-B
;; ;;     + :group-1:func-A/func-B
;; ;;
;; ;;------------------------------


;; ;;------------------------------------------------------------------------------
;; ;; List Ordering
;; ;;------------------------------------------------------------------------------
;; ;;
;; ;;  - List is grouped by keymaps - global (nil) should be first.
;; ;;  - Within a keymap, order keys by general functionality:
;; ;;    + Movement
;; ;;    + etc.
;; ;;  - Within a general functionality, try to break up/order keybinds into
;; ;;    sub-groups.
;; ;;  - If there is a combo-key (e.g. `:digit-arg:0/line:start'), place it in the
;; ;;    first group it belongs to in the list.
;; ;;    + Try to place a commented out or comment about it in other groups it
;; ;;      belongs to.
;; ;;
;; ;;------------------------------


;; ;;------------------------------------------------------------------------------
;; ;; Pretty Formatting
;; ;;------------------------------------------------------------------------------
;; ;; NOTE: ^The above 3 lines are a "headline"
;; ;;   - It is a 'full-width' headline as both hyphen lines go out to column 80.
;; ;;   - A 'medium' headline has 30 hyphens/dashes.
;; ;;   - A 'small' headline has 3 hyphens/dashes.
;; ;;
;; ;; - Try to keep the keybind strings of subgroups or groups aligned.
;; ;;          (:item:jump                 . "%")
;; ;;          (:digit-arg:0/line:start    . "0")
;; ;;          (:line:end                  . "$")
;; ;;          (:line:prev:first-non-blank . "-")
;; ;;
;; ;; - Use a full-width headline between keymaps.
;; ;;   + Try to keep two empty lines between keymaps.
;; ;;
;; ;; - Use a medium headline between groups.
;; ;;   + Try to keep two empty lines between groups.
;; ;;
;; ;; - Use a small headline between subgroups.
;; ;;   + Try to keep one empty line between subgroups.
;; ;;
;; ;;------------------------------


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

;;           ;;---
;;           ;; Word
;;           ;;---
;;           (:word:next:begin               . "w")
;;           (:word:next:end                 . "e")
;;           (:word:prev:begin               . "b")
;;           (:word:next:begin:bigword       . "W") ;; aka (:word:next with optional arg BIGWORD set to 't')
;;           (:word:next:end:bigword         . "E")
;;           (:word:prev:begin:bigword       . "B")

;;           ;;---
;;           ;; Sentences
;;           ;;---
;;           (:sentence:begin:prev           . "(")
;;           (:sentence:begin:next           . ")")

;;           ;;---
;;           ;; Paragraphs
;;           ;;---
;;           (:paragraph:prev                . "{")
;;           (:paragraph:next                . "}")

;;           ;;---
;;           ;; Lines
;;           ;;---
;;           (:item:jump                     . "%") ;; Movement
;;           (:digit-arg:0/line:start        . "0")
;;           (:line:end                      . "$")
;;           (:line:prev:first-non-blank     . "-")
;;           (:line:current:first-non-blank  . "^")
;;           (:line:next-1:first-non-blank   . "_")
;;           (:line:next:first-non-blank     . "+")

;;           ;;---
;;           ;; Go-To Line
;;           ;;---
;;           (:goto:line:first-non-blank     . "G") ;; default: last line in buffer
;;           (:goto:line:visible:first       . "H")
;;           (:goto:line:visible:middle      . "M")
;;           (:goto:line:visible:last        . "L")

;;           ;;---
;;           ;; Searches
;;           ;;---
;;           (:search:next                   . "n")
;;           (:search:prev                   . "N")
;;           (:search:forward                . "/")
;;           (:search:backward               . "?")

;;           (:search:word:backward          . "#")
;;           (:search:word:forward           . "*")

;;           (:snipe:next:1-t                . "t")
;;           (:snipe:next:1-f                . "f")
;;           (:snipe:prev:1-t                . "T")
;;           (:snipe:prev:1-f                . "F")
;;           (:snipe:next:2                  . "s")
;;           (:snipe:prev:2                  . "S")
;;           (:snipe:repeat                  . ";")
;;           (:snipe:repeat:inverse          . ",")

;;           ;;---
;;           ;; Marks
;;           ;;---
;;           (:mark:set                      . "m")
;;           (:mark:goto                     . "`")


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
;;           ;; Evil States
;;           ;;------------------------------
;;           (:state:insert:before           . "i")
;;           (:state:insert:after            . "a")
;;           (:state:insert:line:start       . "I")
;;           (:state:insert:line:end         . "A")
;;           (:state:insert:line:open-below  . "o")
;;           (:state:insert:line:open-above  . "O")
;;           (:state:replace                 . "R")
;;           (:state:visual:char-wise        . "v")
;;           (:state:visual:line-wise        . "V")


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

;; ;;------------------------------------------------------------------------------
;; ;; Registration
;; ;;------------------------------------------------------------------------------

;; (input//kl:layout/init :qwerty
;;                        'input//kl:qwerty:keys
;;                        'input//kl:qwerty:functions)


;; ;;------------------------------------------------------------------------------
;; ;; The End.
;; ;;------------------------------------------------------------------------------
