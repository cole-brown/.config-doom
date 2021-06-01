;;; input/keyboard/layout/evil.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defvar input//kl:definitions:evil:keywords nil
  "Definition of the keywords->functions created by calling
`input:keyboard/layout:evil:define/keywords'.

Multiple calls to `input:keyboard/layout:evil:define/keywords' accumulate the
result here.

Format:
  - alist of lists:
    - lists: (keybind-keyword keybind-function)")


(defvar input//kl:definitions:evil:layout nil
  "Definition of the layout created by calling
`input:keyboard/layout:evil:define/layout'.

Multiple calls to `input:keyboard/layout:evil:define/layout' accumulate the
result here.

Format:
  - alist by layout keyword
    - alist by keymap symbol
      - alist by evil state(s)
        - keybinding entries: list of:
          (keybind-keyword keybind-string optional-function)")


;;------------------------------------------------------------------------------
;; Validity
;;------------------------------------------------------------------------------

(defun input//kl:valid/entry.evil? (entry)
  "Returns ENTRY (aka 'non-nil') if ENTRY is valid.

Raises an error if it is invalid."
  (cond
   ;;------------------------------
   ;; General Checks
   ;;------------------------------
   ((null entry)
    (error "%s: null entry is not valid: %S"
           "input//kl:valid/entry.evil?"
           entry)
    nil)

   ((not (listp entry))
    (error "%s: entry must be a list: %S"
           "input//kl:valid/entry.evil?"
           entry)
    nil)

   ((and (not (= (length entry) 2))
         (not (= (length entry) 3)))
    (error "%s: entry must be a list of length 2 or 3: %S"
           "input//kl:valid/entry.evil?"
           entry)
    nil)

   ;;------------------------------
   ;; Got a list of the right length now - does it have the correct things
   ;; in the correct order?
   ;;------------------------------
   ((not (input//kl:layout:valid/keyword? (nth 0 entry)))
    (error "%s: Entry's first element failed keyword validity check: %S"
           "input//kl:valid/entry.evil?"
           entry)
    nil)

   ((not (input//kl:layout:valid/keybind? (nth 1 entry)))
    (error "%s: Entry's second element failed keybind validity check: %S"
           "input//kl:valid/entry.evil?"
           entry)
    nil)

   ;; Ok if optional func in entry is nil.
   ((not (input//kl:layout:valid/function? (nth 2 entry)))
    (error (concat "%s: Entry's third (and optional) element "
                   "failed function validity check: %S")
           "input//kl:valid/entry.evil?"
           entry)
    nil)

   ;;------------------------------
   ;; Default is: It passed all our failures so it's good.
   ;;------------------------------
   (t
    ;; Could return t, but maybe returning the entry back will help someone
    ;; somewhere.
    entry)))


;;------------------------------------------------------------------------------
;; Normalization
;;------------------------------------------------------------------------------


(defun input//kl:layout:normalize/states (states)
  "Asks Doom to normalize STATES for us.

Doom will raise an error on invalid STATES."
  (doom--map-keyword-to-states states))


(defun input:keyboard/layout:evil:define/layout (enabled layout states keymap
                                                         _docstr
                                                         &rest bindings)
  "Define some BINDINGS for keyboard LAYOUT, evil STATES, and mode KEYMAP.

If ENABLED is nil, this does nothing. Example:
  (input:keyboard/layout:evil:define/keywords (featurep! :emacs undo)
     \"Undo/Redo Keywords if feature flag is set.\"
     ...)
    -> Will define the keywords if `(featurep! :emacs undo)' returns non-nil, or
       ignore them if it returns nil.

LAYOUT should be: a valid layout keyword (:qwerty, :dvorak, etc)
STATES should be: a keyword like `map!' accepts (:normal, :visual, :nv, :mnv, etc.)
KEYMAP should be: a symbol (org-agenda-keymap, evil-snipe-local-mode-map, etc)

_DOCSTR: For you to document your init if desired - not preserved.

BINDINGS: Repeating list of keybind name keyword, keybind string, and optional
function to bind:
  <keyword-0> <string-0> [<function-0>] ...  <- allows overriding functions"
  (declare (indent 4) (doc-string 5))

  (if (not enabled)
      ;; Do a no-op.
      nil

    ;; Ok; we are enabled - define the layout.

    ;; Normalize some of the inputs - raises errors on invalid values.
    (let ((keymap (input//kl:layout:normalize/keymap keymap))
          (states (input//kl:layout:normalize/states states))
          ;; Our vars:
          (expected :keyword)  ; Next type: :keyword, :keybind, :function
          entries  ; Accumulator for all bindings provided in call.
          entry)   ; Accumulator for building one binding out of list of bindings.

      ;;------------------------------
      ;; Build layout entries from bindings...
      ;;------------------------------
      (dolist (each bindings)
        ;;------------------------------
        ;; Optional Types:
        ;;------------------------------
        ;;---
        ;; Function: A function to use instead of the default for the keyword.
        ;;---
        ;; `:function' is optional, so deal with it separately and before the
        ;; others. We'll skip forward if it fails to satisfy the requirements
        ;; for the option.
        (when (eq expected :function)
          (if (not (input//kl:layout:valid/function? each))
              ;; Not a function. Skip forward to "is it a keyword?".
              (setq expected :keyword)

            ;; Found optional func arg - add to entry.
            (push each entry)
            ;; NOTE: LEAVE `expected' AS-IS!
            ;; It's our "skip to the next entry" indicator to short-cut out of the
            ;; "required types" block.
            ))

        ;;------------------------------
        ;; Required Types:
        ;;------------------------------
        (cond
         ((eq expected :function)
          ;; Found and processed an optional function arg; done with this entry.
          (setq expected :keyword))

         ;;---
         ;; Keyword: End of Previous and Start of Next Entry.
         ;;---
         ((eq expected :keyword)
          (if (not (input//kl:layout:valid/keyword? each))
              (error (concat "input:keyboard/layout:evil:define/layout: "
                             "Keyword '%S' failed validity checks.")
                     each)

            ;;---
            ;; Finish previous entry.
            ;;---
            ;; - Complain if invalid entry.
            (when entry
              ;; We built it backwards, so un-backwards it.
              (setq entry (nreverse entry))
              (if (input//kl:valid/entry.evil? entry)
                  ;; Valid entry; save to list.
                  (push entry entries)

                ;; Invalid: `input//kl:valid/entry.evil?' should have raised
                ;; a more specific error already, but to be safe:
                (error (concat "input:keyboard/layout:evil:define/layout: "
                               "Binding %S failed validity checks.")
                       entry)))

            ;;---
            ;; Start new entry.
            ;;---
            ;; - Make sure we overwrite the old entry; no `push'.
            (setq entry (list each))

            ;; Must have :keybind next.
            (setq expected :keybind)))

         ;;---
         ;; Keybind: `kbd' type string
         ;;---
         ((eq expected :keybind)
          (if (not (input//kl:layout:valid/keybind? each))
              (error (concat "input:keyboard/layout:evil:define/layout: "
                             "Keybind '%S' failed validity checks.")
                     each)
            ;; Found keybind - add to entry.
            (push each entry)

            ;; :function will do the "but I'm optional!" stuff.
            (setq expected :function)))

         ;;---
         ;; Default: Something Bad Happened.
         ;;---
         (t
          (error (concat "input:keyboard/layout:evil:define/layout: "
                         "Unexpected `expected' state '%S' encountered "
                         "when parsing BINDINGS. "
                         "Expected `expected' states: %S")
                 expected
                 '(:keyword :keybind :function)))))

      ;;------------------------------
      ;; Finish final entry.
      ;;------------------------------
      ;; Entry is built backwards, so fix that.
      (setq entry (nreverse entry))
      (if (input//kl:valid/entry.evil? entry)
          ;; Valid entry; save to list.
          (push entry entries)

        ;; Invalid: `input//kl:valid/entry.evil?' should have raised
        ;; a more specific error already, but to be safe:
        (error (concat "input:keyboard/layout:evil:define/layout: "
                       "Final binding %S failed validity checks.")
               entry))

      ;; Complain if no entries.
      (unless entries
        (error (concat "input:keyboard/layout:evil:define/layout: "
                       "No layout bindings found in `bindings' parameter? "
                       "bindings: %S")
               bindings))

      ;;------------------------------
      ;; Add entries to `input//kl:layout:definition:evil'.
      ;;------------------------------

      ;;---
      ;; 1) Get alist to update from our layout definitions alist.
      ;;---
      (let* ((alist/layout (input//kl:alist/get layout
                                                input//kl:definitions:evil:layout))
             (alist/keymap (input//kl:alist/get keymap
                                                alist/layout))
             (alist/states (input//kl:alist/get states
                                                alist/keymap)))
        ;;---
        ;; 2) Update keymap alist w/ new/updated bindings.
        ;;---
        (dolist (binding entries)
          ;; We do want to overwrite existing, so we will do it one-by-one...
          (input//kl:alist/update (car binding)
                                  (cdr binding)
                                  alist/states
                                  t))

        ;;---
        ;; 3) Update alists.
        ;;---
        ;; Updated `alist/states', now push that into `alist/keymaps'...
        (input//kl:alist/update states alist/states alist/keymap t)
        ;; ...and `alist/keymaps' goes back into `alist/layout'...
        (input//kl:alist/update keymap alist/keymap alist/layout t)
        ;; ...and finally update the definitions with our updated layout.
        (input//kl:alist/update layout alist/layout input//kl:definitions:evil:layout t)

        ;;---
        ;; 4) Done; what do we want to return?
        ;;---
        ;; The updated keymap maybe?
        alist/keymap))))
;; (input:keyboard/layout:evil:define/layout :enabled :spydez :nvm 'global
;;   "Test making some bindings for the global keybinds."
;;   :line:prev "k"
;;   :line:next "j" 'ignore
;;   :char:next "h" #'identity
;;   :char:prev "l" #'undefined-so-far)


(defun input:keyboard/layout:evil:define/keywords (enabled _docstr &rest bindings)
  "Define the keyword->function BINDINGS.

If ENABLED is nil, this does nothing. Example:
  (input:keyboard/layout:evil:define/keywords (featurep! :emacs undo)
     \"Undo/Redo Keywords if feature flag is set.\"
     ...)
    -> Will define the keywords if `(featurep! :emacs undo)' returns non-nil, or
       ignore them if it returns nil.

_DOCSTR: For you to document if desired - not preserved.

BINDINGS: Repeating list of: keyword, function"
  (declare (indent 1) (doc-string 2))

  (if (not enabled)
      ;; Do a no-op.
      nil

    ;; Ok; we are enabled - define the keywords.
    (let ((expected :keyword)  ; Next type: :keyword, :function
          entries  ; Accumulator for all bindings provided in call.
          entry)   ; Accumulator for building one binding out of list of bindings.

      ;;------------------------------
      ;; Build layout entries from bindings...
      ;;------------------------------
      (dolist (each bindings)
        (cond
         ;;---
         ;; Keyword: End of Previous and Start of Next Entry.
         ;;---
         ((eq expected :keyword)
          (if (not (keywordp each))
              (error (concat "input:keyboard/layout:evil:define/keywords: "
                             "Keyword '%S' failed validity checks.")
                     each)

            ;;---
            ;; Finish previous entry.
            ;;---
            ;; - Complain if invalid entry.
            (when entry
              ;; We built it backwards, so un-backwards it.
              (setq entry (nreverse entry))
              (if (and
                   ;; Is keyword valid?
                   (keywordp (nth 0 entry))
                   ;; Is function valid?
                   (and (symbolp (nth 1 entry))
                        (not (keywordp (nth 1 entry)))))
                  ;; Valid; save it.
                  (push entry entries)

                ;; Invalid: raise an error:
                (error (concat "input:keyboard/layout:evil:define/keywords: "
                               "Keyword entry %S failed validity checks.")
                       entry)))

            ;;---
            ;; Start new entry.
            ;;---
            ;; - Make sure we overwrite the old entry; no `push'.
            (setq entry (list each))

            ;; Must have :function next.
            (setq expected :function)))

         ((eq expected :function)
          ;;---
          ;; Function: A function to use instead of the default for the keyword.
          ;;---
          (when (eq expected :function)
            (if (and (symbolp entry)
                     (not (keywordp entry)))
                ;; Valid; add to entry.
                (push each entry)

              ;; Invalid: raise an error:
              (error (concat "input:keyboard/layout:evil:define/keywords: "
                             "Function '%S' failed validity checks.")
                     entry)))

          ;; Must have keyword or end of the list next.
          (setq expected :keyword))

         ;;---
         ;; Default: Something Bad Happened.
         ;;---
         (t
          (error (concat "input:keyboard/layout:evil:define/keywords: "
                         "Unexpected `expected' state '%S' encountered "
                         "when parsing BINDINGS. "
                         "Expected `expected' states: %S")
                 expected
                 '(:keyword :function)))))

      ;;------------------------------
      ;; Finish final entry.
      ;;------------------------------
      ;; We built it backwards, so un-backwards it.
      (setq entry (nreverse entry))
      (if (and
           ;; Is keyword valid?
           (keywordp (nth 0 entry))
           ;; Is function valid?
           (and (symbolp (nth 1 entry))
                (not (keywordp (nth 1 entry)))))
          ;; Valid; save it.
          (push entry entries)

        ;; Invalid: raise an error:
        (error (concat "input:keyboard/layout:evil:define/keywords: "
                       "Keyword entry %S failed validity checks.")
               entry))

      ;; Complain if no entries.
      (unless entries
        (error (concat "input:keyboard/layout:evil:define/keywords: "
                       "No layout keywords found in `bindings' parameter? "
                       "bindings: %S")
               bindings))

      ;;------------------------------
      ;; Add entries to `input//kl:layout:definition:evil:keywords'.
      ;;------------------------------
      ;;---
      ;; Update alist w/ new/updated bindings.
      ;;---
      (dolist (binding entries)
        ;; We do want to overwrite existing, so we will do it one-by-one...
        (input//kl:alist/update (car binding)
                                (cdr binding)
                                input//kl:definitions:evil:keywords
                                t))
      ;;---
      ;; Done; what do we want to return?
      ;;---
      ;; IDK... the full alist?
      input//kl:definitions:evil:keywords)))
;; TODO: HERE YOU ARE- MH, YES.
;;       - Make a test call for this!
;;       - And then test it!
;; (input:keyboard/layout:evil:define/keywords
;;     :enabled
;;   "docstring here"
;;   :test:keyword #'ignore)


;;------------------------------------------------------------------------------
;; Create Keywords
;;------------------------------------------------------------------------------

(input:keyboard/layout:evil:define/keywords
    :enabled
  ";;------------------------------
   ;; Movement
   ;;------------------------------"

  ;;---
  ;; Up/Down/Left/Right
  ;;---
  :line:prev                     #'evil-previous-line
  :line:next                     #'evil-next-line
  :char:next                     #'evil-backward-char
  :char:prev                     #'evil-forward-char

  ;;---
  ;; Word
  ;;---
  :word:next:begin               #'evil-forward-word-begin
  :word:next:end                 #'evil-forward-word-end
  :word:prev:begin               #'evil-backward-word-begin
  :word:next:begin:bigword       #'evil-forward-WORD-begin
  :word:next:end:bigword         #'evil-forward-WORD-end
  :word:prev:begin:bigword       #'evil-backward-WORD-begin

  ;;---
  ;; Sentences
  ;;---
  :sentence:begin:prev           #'evil-backward-sentence-begin
  :sentence:begin:next           #'evil-forward-sentence-begin

  ;;---
  ;; Paragraphs
  ;;---
  :paragraph:prev                #'evil-backward-paragraph
  :paragraph:next                #'evil-forward-paragraph

  ;;---
  ;; Lines
  ;;---
  :item:jump                     #'evil-jump-item
  :digit-arg:0/line:start        #'evil-digit-argument-or-evil-beginning-of-line
  :line:end                      #'evil-end-of-line
  :line:prev:first-non-blank     #'evil-previous-line-first-non-blank
  :line:current:first-non-blank  #'evil-first-non-blank
  :line:next-1:first-non-blank   #'evil-next-line-1-first-non-blank
  :line:next:first-non-blank     #'evil-next-line-first-non-blank

  ;;---
  ;; Go-To Line
  ;;---
  :goto:line:first-non-blank     #'evil-goto-line ;; default: last line in buffer
  :goto:line:visible:first       #'evil-window-top
  :goto:line:visible:middle      #'evil-window-middle
  :goto:line:visible:last        #'evil-window-bottom

  ;;---
  ;; Searches
  ;;---
  :search:next                   #'evil-ex-search-next ; TODO: double check w/ qwerty bindings on. "n"
  :search:prev                   #'evil-ex-search-previous
  :search:forward                #'evil-ex-search-forward
  :search:backward               #'evil-ex-search-backward

  :search:word:backward          #'evil-ex-search-word-backward
  :search:word:forward           #'evil-ex-search-word-forward

  ;; TODO: snipe seems very tied to its keys that it has hard-coded...
  ;; May need to use `evil-snipe-def' to invent new ones...
  :snipe:next:1-t                #'evil-snipe-t
  :snipe:next:1-f                #'evil-snipe-f
  :snipe:prev:1-t                #'evil-snipe-T
  :snipe:prev:1-f                #'evil-snipe-F
  :snipe:next:2                  #'evil-snipe-s
  :snipe:prev:2                  #'evil-snipe-S
  :snipe:repeat                  #'evil-snipe-repeat
  :snipe:repeat:inverse          #'evil-snipe-repeat-reverse

  ;;---
  ;; Marks
  ;;---
  :mark:set                      #'evil-set-marker
  :mark:goto                     #'evil-goto-mark)


(input:keyboard/layout:evil:define/keywords
    :enabled
  ";;------------------------------
   ;; Repeating
   ;;------------------------------"
  :digit-arg:1                   #'digit-argument
  :digit-arg:2                   #'digit-argument
  :digit-arg:3                   #'digit-argument
  :digit-arg:4                   #'digit-argument
  :digit-arg:5                   #'digit-argument
  :digit-arg:6                   #'digit-argument
  :digit-arg:7                   #'digit-argument
  :digit-arg:8                   #'digit-argument
  :digit-arg:9                   #'digit-argument
  ;; defined in -Movement-
  ;; :digit-arg:0/line:start     #'evil-digit-argument-or-evil-beginning-of-line
  )


;; TODO: HERE YOU ARE- MH, YES.
;;       - Finish the rest:
;; TODO: I don't really need to enable/disable these - best to have all keywords
;; around in case someone wants to map them.
(input:keyboard/layout:evil:define/keywords
    ;; If :emacs/undo flag defined, define all undo keywords.
    (featurep! :emacs undo)
  ";;------------------------------
   ;; Text Maniplutaion - :emacs/undo enabled
   ;;------------------------------"

  ;;---
  ;; Undo/Redo
  ;;---
  :text:undo                     #'evil-undo
  ;; `evil-redo' is mapped when :emacs/undo is enabled.
  :text:redo                     #'evil-redo

  ;;---
  ;; Replace
  ;;---
  ;; ...and `evil-replace' isn't mapped.
  ;; :char:replace                  #'evil-replace
  )
(input:keyboard/layout:evil:define/keywords
    ;; If :emacs/undo flag defined, define all undo keywords.
    (not (featurep! :emacs undo))
  ";;------------------------------
   ;; Text Maniplutaion - :emacs/undo DISABLED
   ;;------------------------------"

  ;;---
  ;; Undo/Redo
  ;;---
  :text:undo                     #'evil-undo
  ;; `evil-redo' isn't mapped without :emacs/undo enabled.
  ;; :text:redo                     #'evil-redo

  ;;---
  ;; Replace
  ;;---
  ;; ...`evil-replace' is mapped instead.
  :char:replace                  #'evil-replace)


(input:keyboard/layout:evil:define/keywords
    :enabled
  ";;------------------------------
   ;; Text Maniplutaion
   ;;------------------------------"

  ;;---
  ;; Copy/Cut/Paste
  ;;---
  :kill-ring:copy                #'evil-yank
  :kill-ring:copy:line           #'evil-yank-line
  :text:delete                   #'evil-delete
  :text:delete:line:point-to-end #'evil-delete-line
  :paste:after                   #'evil-paste-after
  :paste:before                  #'evil-paste-before
  :char:delete:current           #'evil-delete-char
  :char:delete:prev              #'evil-delete-backward-char

  ;; "Change" meaning "delete and put me in insert mode"?
  :change:dwim                   #'evil-change  ; TODO: double check w/ qwerty bindings on. "c")
  :change:line:point-to-end      #'evil-change-line

  ;;---
  ;; Indent/Outdent
  ;;---
  :text:shift:left               #'evil-shift-left
  :text:shift:right              #'evil-shift-right
  :indent                        #'evil-indent

  ;;---
  ;; Upper/Lower Case
  ;;---
  :case:invert                   #'evil-invert-char

  ;;---
  ;; Replace
  ;;---
  :replace:repeat                #'evil-ex-repeat-substitute  ;; Same as: :s//~/

  ;;---
  ;; Line-Based
  ;;---
  :line:join:next-to-current     #'evil-join

  ;;---
  ;; Macros (not Emacs macros)
  ;;---
  :macro:record                  #'evil-record-macro
  :macro:execute                 #'evil-execute-macro

  ;;---
  ;; Repeat "the last editing command".
  ;;---
  :edit:repeat                   #'evil-repeat)

;; TODO: HERE YOU ARE- MH, YES.
;;       - Finish the rest:
;; (input:keyboard/layout:evil:define/keywords
;;     :enabled
;;   ";;------------------------------
;;  ;; Commands
;;  ;;------------------------------
;;  ;;---
;;  ;; Evil Command
;;  ;;---
;;  :evil:command                  #'evil-ex

;;  ;;---
;;  ;; Shell Command
;;  ;;---
;;  :shell:command                 #'evil-shell-command) ;; Execute region as shell command?

;;  ;;------------------------------
;;  ;; Evil States
;;  ;;------------------------------
;;  :state:insert:before           #'evil-insert
;;  :state:insert:after            #'evil-append
;;  :state:insert:line:start       #'evil-insert-line
;;  :state:insert:line:end         #'evil-append-line
;;  :state:insert:line:open-below  #'evil-open-below
;;  :state:insert:line:open-above  #'evil-open-above
;;  :state:replace                 #'evil-replace-state
;;  :state:visual:char-wise        #'evil-visual-char
;;  :state:visual:line-wise        #'evil-visual-line


;;  ;;------------------------------
;;  ;; Doom!
;;  ;;------------------------------
;;  :docs:lookup                   #'+lookup/documentation


;;  ;;------------------------------
;;  ;; No Keybind
;;  ;;------------------------------
;;  :undefined                     nil


;;  ;;------------------------------
;;  ;; TODO: All the multi-key keybinds
;;  ;;------------------------------
;;  ;; These aren't keybinds - they just have a lot of keybinds in them.
;;  ;; (:menu:prev  . #'"[")
;;  ;; (:menu:next  . #'"]")
;;  ;; (:menu:text? . #'"g")
;;  ;; (:menu:???   . #'"z")
;;  ;; (:menu:???   . #'"Z")


;;  ;;------------------------------
;;  ;; TODO: All the modifier keybinds (Ctrl, Shift, etc)
;;  ;;------------------------------
;;  ;; like, do everything all over again but with Ctrl.
;;  ;; ...and then shift...
;;  ;; ...and then etc...
;;  )

;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------
