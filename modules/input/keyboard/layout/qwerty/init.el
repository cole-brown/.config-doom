;;; input/keyboard/layout/qwerty/init.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Keyword Naming
;;------------------------------------------------------------------------------
;;
;; - Try to be succinct; use short synonymns.
;;   + Instead of 'beginning', use 'start'.
;; - Try to modify the function name into a symbol based on these guidelines
;;   (as opposed to just making up something that feels better).
;;   + `beginning-of-line' -> `:line:start' as opposed to, say, `:point:bol'.
;; - Try to use words instead of acronyms.
;;   + E.g. "file end" or "end of file" instead of "eof" should be what you try
;;     to make your symbol out of.
;; - Be specific:
;;   + `evil-previous-line-first-non-blank'
;;     - YES: `:line:prev-non-blank'
;;     -  NO: `:line:prev'
;;     - Someone may want to use `evil-previous-line' everywhere instead of
;;       `evil-previous-line-first-non-blank' and they should be the ones to
;;       claim `:line:prev'.
;;
;;------------------------------
;; Groupings:
;;---
;;   - If a key has a general grouping and a specific functionality in that
;;     group of commands, order general->specific and separate with colons.
;;     + :group-1:func-A
;;     + :group-1:func-B
;;     + :line:next
;;     + :line:prev
;;     + :line:prev-non-blank
;;
;;
;;------------------------------
;; Combos / Multi-Function:
;;---
;;   - If a key has multiple functionalities, depending on context, separate
;;     them with a '/' character.
;;     + :func-A/func-B
;;   - If a key has different functionalities, depending on setup, use separate
;;     `when's instead of a single `if' block so they can be place properly.
;;     + YES:
;;          <some section>
;;          (when (featurep! :emacs undo)
;;            (:undo:redo . "r"))
;;          ...
;;          <some other section>
;;          (when (not (featurep! :emacs undo))
;;            (:char:replace . "r"))
;;     + NO:
;;          (if (featurep! :emacs undo)
;;              (:undo:redo . "r")
;;            (:char:replace . "r"))
;;
;;
;;------------------------------
;; Combining:
;;---
;;   - Do the best you can, but you may not always be able to follow the
;;     guidelines completely if in some hybrid of two or more things.
;;   - E.g.: a grouping and a combo:
;;     + :func-A/group-1:func-B
;;     + :group-1:func-A/func-B
;;
;;------------------------------


;;------------------------------------------------------------------------------
;; List Ordering
;;------------------------------------------------------------------------------
;;
;;  - List is grouped by keymaps - global (nil) should be first.
;;  - Within a keymap, order keys by general functionality:
;;    + Movement
;;    + etc.
;;  - Within a general functionality, try to break up/order keybinds into
;;    sub-groups.
;;  - If there is a combo-key (e.g. `:digit-arg:0/line:start'), place it in the
;;    first group it belongs to in the list.
;;    + Try to place a commented out or comment about it in other groups it
;;      belongs to.
;;
;;------------------------------


;;------------------------------------------------------------------------------
;; Pretty Formatting
;;------------------------------------------------------------------------------
;; NOTE: ^The above 3 lines are a "headline"
;;   - It is a 'full-width' headline as both hyphen lines go out to column 80.
;;   - A 'medium' headline has 30 hyphens/dashes.
;;   - A 'small' headline has 3 hyphens/dashes.
;;
;; - Try to keep the keybind strings of subgroups or groups aligned.
;;          (:item:jump                 . "%")
;;          (:digit-arg:0/line:start    . "0")
;;          (:line:end                  . "$")
;;          (:line:prev:first-non-blank . "-")
;;
;; - Use a full-width headline between keymaps.
;;   + Try to keep two empty lines between keymaps.
;;
;; - Use a medium headline between groups.
;;   + Try to keep two empty lines between groups.
;;
;; - Use a small headline between subgroups.
;;   + Try to keep one empty line between subgroups.
;;
;;------------------------------


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defvar input//kl:qwerty:keys
  '(;;-------------------------------------------------------------------------
    ;; Global Keymap
    ;;-------------------------------------------------------------------------
    (nil .
         (;;------------------------------
          ;; Movement
          ;;------------------------------
          ;;---
          ;; Up/Down/Left/Right
          ;;---
          (:line:prev                     . "k")
          (:line:next                     . "j")
          (:char:next                     . "h")
          (:char:prev                     . "l")

          ;;---
          ;; Word
          ;;---
          (:word:next:begin               . "w")
          (:word:next:end                 . "e")
          (:word:next:begin:bigword       . "W") ;; aka (:word:next with optional arg BIGWORD set to 't')
          (:word:next:end:bigword         . "E")
          (:word:prev:begin               . "b")
          (:word:prev:begin:bigword       . "B")

          ;;---
          ;; Sentences
          ;;---
          (:sentence:begin:reverse        . "(")
          (:sentence:begin:forward        . ")")

          ;;---
          ;; Paragraphs
          ;;---
          (:paragraph:prev                . "{")
          (:paragraph:next                . "}")

          ;;---
          ;; Lines
          ;;---
          (:item:jump                     . "%") ;; Movement
          (:digit-arg:0/line:start        . "0")
          (:line:end                      . "$")
          (:line:prev:first-non-blank     . "-")
          (:line:current:first-non-blank  . "^")
          (:line:next-1:first-non-blank   . "_")
          (:line:next:first-non-blank     . "+")

          ;;---
          ;; Go-To Line
          ;;---
          (:goto:line:first-non-blank     . "G") ;; default: last line in buffer
          (:goto:line:visible:first       . "H")
          (:goto:line:visible:last        . "L")
          (:goto:line:visible:middle      . "M")

          ;;---
          ;; Searches
          ;;---
          (:search:forward                . "n")
          (:search:forward                . "/")
          (:search:prev                   . "N")
          (:search:prev                   . "?")

          (:search:word:reverse           . "#")
          (:search:word:forward           . "*")

          (:snipe:next:1                  . "t")
          (:snipe:next:1                  . "f")
          (:snipe:prev:1                  . "T")
          (:snipe:prev:1                  . "F")
          (:snipe:next:2                  . "s")
          (:snipe:prev:2                  . "S")
          (:snipe:repeat                  . ";")
          (:snipe:repeat:inverse          . ",")

          ;;---
          ;; Marks
          ;;---
          (:mark:set                      . "m")
          (:mark:goto                     . "`")


          ;;------------------------------
          ;; Repeating
          ;;------------------------------
          (:digit-arg:1                   . "1")
          (:digit-arg:2                   . "2")
          (:digit-arg:3                   . "3")
          (:digit-arg:4                   . "4")
          (:digit-arg:5                   . "5")
          (:digit-arg:6                   . "6")
          (:digit-arg:7                   . "7")
          (:digit-arg:8                   . "8")
          (:digit-arg:9                   . "9")
          ;; (:digit-arg:0/line:start     . "0")


          ;;------------------------------
          ;; Text Maniplutaion
          ;;------------------------------

          ;;---
          ;; Undo/Redo
          ;;---
          (:text:undo                     . "u")
          (when (featurep! :emacs undo)
            (:text:redo                   . "r"))

          ;;---
          ;; Copy/Cut/Paste
          ;;---
          (:kill-ring:copy                . "y")
          (:kill-ring:copy:line           . "Y")
          (:text:delete:line:point-to-end . "D")
          (:text:delete                   . "d")
          (:paste:after                   . "p")
          (:paste:before                  . "P")
          (:char:delete:current           . "x")
          (:char:delete:prev              . "X")

          ;; "Change" meaning "delete and put me in insert mode"?
          (:change:dwim                   . "c")
          (:change:line:point-to-end      . "C")

          ;;---
          ;; Indent/Outdent
          ;;---
          (:text:shift:left               . "<")
          (:text:shift:right              . ">")
          (:indent                        . "=")

          (:case:invert                   . "~")
          (:replace:repeat                . "&")  ;; Same as: :s//~/
          (when (not (featurep! :emacs undo))
            (:char:replace                . "r"))

          ;;---
          ;; Line-Based
          ;;---
          (:line:join:next-to-current     . "J")

          ;;---
          ;; Macros (not Emacs macros)
          ;;---
          (:macro:record                  . "q")
          (:macro:execute                 . "@")

          ;;---
          ;; Repeat "the last editing command".
          ;;---
          (:edit:repeat                   . ".")

          ;;------------------------------
          ;; Commands
          ;;------------------------------
          ;;---
          ;; Evil Command
          ;;---
          (:evil:command                  . ":")

          ;;---
          ;; Shell Command
          ;;---
          (:shell:command                 . "!")  ;; Execute region as shell command?

          ;;------------------------------
          ;; Evil States
          ;;------------------------------
          (:state:insert:before           . "i")
          (:state:insert:after            . "a")
          (:state:insert:line:start       . "I")
          (:state:insert:line:end         . "A")
          (:state:insert:line:open-below  . "o")
          (:state:insert:line:open-above  . "O")
          (:state:replace                 . "R")
          (:state:visual:char-wise        . "v")
          (:state:visual:line-wise        . "V")


          ;;------------------------------
          ;; Misc.
          ;;------------------------------
          (:docs:lookup                   . "K")


          ;;------------------------------
          ;; No Keybind
          ;;------------------------------
          (:undefined                     . "Q")
          (:undefined                     . "U")


          ;;------------------------------
          ;; TODO: All the multi-key keybinds
          ;;------------------------------
          ;; These aren't keybinds - they just have a lot of keybinds in them.
          ;; (:menu:prev  . "[")
          ;; (:menu:next  . "]")
          ;; (:menu:text? . "g")
          ;; (:menu:???   . "z")
          ;; (:menu:???   . "Z")


          ;;------------------------------
          ;; TODO: All the modifier keybinds (Ctrl, Shift, etc)
          ;;------------------------------
          ;; like, do everything all over again but with Ctrl.
          ;; ...and then shift...
          ;; ...and then etc...
          ))


    ;;--------------------------------------------------------------------------
    ;; TODO: A bunch of other mode maps.
    ;;--------------------------------------------------------------------------
    )
  "Keyword -> kbd string alist for the active/desired keyboard layout.")


(defvar input//kl:qwerty:functions
  '(;;--------------------------------------------------------------------------
    ;; Global Keymap
    ;;--------------------------------------------------------------------------
    (nil .
         (;;------------------------------
          ;; Movement
          ;;------------------------------
          (:up    . #'evil-previous-line)
          (:down  . #'evil-next-line)
          (:left  . #'evil-backward-char)
          (:right . #'evil-forward-char)

          ;; TODO: updated to input//kl:qwerty:keys

          )))
  "Keymap -> Keyword -> function alists for the active/desired keyboard
layout.")


;;------------------------------------------------------------------------------
;; Registration
;;------------------------------------------------------------------------------

(input//kl:layout/init :qwerty
                       'input//kl:qwerty:keys
                       'input//kl:qwerty:functions)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
