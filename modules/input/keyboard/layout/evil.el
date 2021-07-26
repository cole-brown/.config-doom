;;; input/keyboard/layout/evil.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                          Evil-Only Keybinds.                           ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;         Modal keyboard input isn't exactly Lawful Good, I guess...         ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Create Keywords
;;------------------------------------------------------------------------------

(input:keyboard/layout:define/keywords :evil
  "┌─────────────────────────────────────────────────────────────────────────┐
   │ Movement                                                                │
   └─────────────────────────────────────────────────────────────────────────┘"

  ;; ┌──────────────────────────────┐
  ;; ├ Up/Down/Left/Right           ┤
  ;; └──────────────────────────────┘
  :layout:evil:line-prev                     #'evil-previous-line
  :layout:evil:line-next                     #'evil-next-line
  :layout:evil:char-prev                     #'evil-backward-char
  :layout:evil:char-next                     #'evil-forward-char

  ;; ┌──────────────────────────────┐
  ;; ├ Word                         ┤
  ;; └──────────────────────────────┘
  :layout:evil:word-prev-begin               #'evil-backward-word-begin
  :layout:evil:word-prev-end                 #'evil-backward-word-end ;; Not mapped in default/qwerty.
  :layout:evil:word-next-begin               #'evil-forward-word-begin
  :layout:evil:word-next-end                 #'evil-forward-word-end
  :layout:evil:word-prev-begin-bigword       #'evil-backward-WORD-begin
  :layout:evil:word-prev-end-bigword         #'evil-backward-WORD-end ;; Not mapped in default/qwerty.
  :layout:evil:word-next-begin-bigword       #'evil-forward-WORD-begin
  :layout:evil:word-next-end-bigword         #'evil-forward-WORD-end

  ;; ┌──────────────────────────────┐
  ;; ├ Sentences                    ┤
  ;; └──────────────────────────────┘
  :layout:evil:sentence-begin-prev           #'evil-backward-sentence-begin
  :layout:evil:sentence-begin-next           #'evil-forward-sentence-begin

  ;; ┌──────────────────────────────┐
  ;; ├ Paragraphs                   ┤
  ;; └──────────────────────────────┘
  :layout:evil:paragraph-prev                #'evil-backward-paragraph
  :layout:evil:paragraph-next                #'evil-forward-paragraph

  ;; ┌──────────────────────────────┐
  ;; ├ Lines                        ┤
  ;; └──────────────────────────────┘
  :layout:evil:item-jump                     #'evil-jump-item
  :layout:evil:digit-arg-0/line-start        #'evil-digit-argument-or-evil-beginning-of-line

  :layout:evil:line-begin                    #'evil-beginning-of-line
  :layout:evil:line-end                      #'evil-end-of-line
  :layout:evil:line-begin-visual             #'evil-beginning-of-visual-line
  :layout:evil:line-end-visual               #'evil-end-of-visual-line
  :layout:evil:line-end/line-end-visual      #'evil-end-of-line-or-visual-line

  :layout:evil:line-prev-first-non-blank     #'evil-previous-line-first-non-blank
  :layout:evil:line-current-first-non-blank  #'evil-first-non-blank
  :layout:evil:line-next-1-first-non-blank   #'evil-next-line-1-first-non-blank
  :layout:evil:line-next-first-non-blank     #'evil-next-line-first-non-blank

  :layout:evil:goto-line-first               #'evil-goto-first-line
  ;; :layout:evil:goto-line-last             #'evil-goto-last-line ;; <-- Does not exist.
  :layout:evil:goto-line                     #'evil-goto-line ;; default: last line in buffer
  :layout:evil:goto-line-window-first        #'evil-window-top
  :layout:evil:goto-line-window-middle       #'evil-window-middle
  :layout:evil:goto-line-window-last         #'evil-window-bottom

  ;; ┌──────────────────────────────┐
  ;; ├ Scroll                       ┤
  ;; └──────────────────────────────┘
  :layout:evil:scroll-up                     #'evil-scroll-up
  :layout:evil:scroll-down                   #'evil-scroll-down
  :layout:evil:scroll-left                   #'evil-scroll-left
  :layout:evil:scroll-right                  #'evil-scroll-right
  :layout:evil:scroll-line-to-top            #'evil-scroll-line-to-top
  :layout:evil:scroll-line-to-center         #'evil-scroll-line-to-center
  :layout:evil:scroll-line-to-bottom         #'evil-scroll-line-to-bottom
  :layout:evil:scroll-page-up                #'evil-scroll-page-up
  :layout:evil:scroll-page-down              #'evil-scroll-page-down
  :layout:evil:scroll-line-up                #'evil-scroll-line-up
  :layout:evil:scroll-line-down              #'evil-scroll-line-down
  :layout:evil:scroll-column-left            #'evil-scroll-column-left
  :layout:evil:scroll-column-right           #'evil-scroll-column-right
  :layout:evil:scroll-count-reset            #'evil-scroll-count-reset  ;; Unused in qwerty.

  ;; ┌──────────────────────────────┐
  ;; ├ Searches                     ┤
  ;; └──────────────────────────────┘
  :layout:evil:search-next                   #'evil-ex-search-next
  :layout:evil:search-prev                   #'evil-ex-search-previous
  :layout:evil:search-forward                #'evil-ex-search-forward
  :layout:evil:search-backward               #'evil-ex-search-backward

  :layout:evil:search-word-backward          #'evil-ex-search-word-backward
  :layout:evil:search-word-forward           #'evil-ex-search-word-forward

  ;; TODO: snipe seems very tied to its keys that it has hard-coded...
  ;; May need to use `evil-snipe-def' to invent new ones...
  :layout:evil:snipe-next-1-t                #'evil-snipe-t ;; TODO: not a keyboard-dependent keyword?
  :layout:evil:snipe-next-1-f                #'evil-snipe-f ;; TODO: not a keyboard-dependent keyword?
  :layout:evil:snipe-prev-1-t                #'evil-snipe-T ;; TODO: not a keyboard-dependent keyword?
  :layout:evil:snipe-prev-1-f                #'evil-snipe-F ;; TODO: not a keyboard-dependent keyword?
  :layout:evil:snipe-next-2-s                #'evil-snipe-s ;; TODO: not a keyboard-dependent keyword?
  :layout:evil:snipe-prev-2-S                #'evil-snipe-S ;; TODO: not a keyboard-dependent keyword?
  :layout:evil:snipe-repeat                  #'evil-snipe-repeat
  :layout:evil:snipe-repeat-inverse          #'evil-snipe-repeat-reverse

  ;; ┌──────────────────────────────┐
  ;; ├ Marks                        ┤
  ;; └──────────────────────────────┘
  :layout:evil:mark-set                      #'evil-set-marker
  :layout:evil:mark-goto                     #'evil-goto-mark)


(input:keyboard/layout:define/keywords :evil
  "┌─────────────────────────────────────────────────────────────────────────┐
   │ Repeating                                                               │
   └─────────────────────────────────────────────────────────────────────────┘"
  :layout:evil:digit-arg-1                   #'digit-argument
  :layout:evil:digit-arg-2                   #'digit-argument
  :layout:evil:digit-arg-3                   #'digit-argument
  :layout:evil:digit-arg-4                   #'digit-argument
  :layout:evil:digit-arg-5                   #'digit-argument
  :layout:evil:digit-arg-6                   #'digit-argument
  :layout:evil:digit-arg-7                   #'digit-argument
  :layout:evil:digit-arg-8                   #'digit-argument
  :layout:evil:digit-arg-9                   #'digit-argument
  ;;---
  ;; Defined in -Movement-. Could redefine here (it just overwrites previous
  ;; definition of the keyword) if we're sure we can keep these names in sync,
  ;; but I'm not so I'm leaving it out.
  ;;---
  ;; :layout:evil:digit-arg-0/line-start     #'evil-digit-argument-or-evil-beginning-of-line
  )


(input:keyboard/layout:define/keywords :evil
  "┌─────────────────────────────────────────────────────────────────────────┐
   │ Text Manipulation                                                       │
   └─────────────────────────────────────────────────────────────────────────┘"

  ;; ┌──────────────────────────────┐
  ;; ├ Undo/Redo                    ┤
  ;; └──────────────────────────────┘
  :layout:evil:text-undo                     #'evil-undo
  ;; `evil-redo' is mapped when ':emacs/undo' is enabled.
  :layout:evil:text-redo                     #'evil-redo

  ;; ┌──────────────────────────────┐
  ;; ├ Copy/Cut/Paste               ┤
  ;; └──────────────────────────────┘
  :layout:evil:kill-ring-copy                #'evil-yank
  :layout:evil:kill-ring-copy-line           #'evil-yank-line
  :layout:evil:text-delete                   #'evil-delete
  :layout:evil:text-delete-line-point-to-end #'evil-delete-line
  :layout:evil:paste-after                   #'evil-paste-after
  :layout:evil:paste-before                  #'evil-paste-before
  :layout:evil:char-delete-current           #'evil-delete-char
  :layout:evil:char-delete-prev              #'evil-delete-backward-char

  ;; "Change" meaning "delete and put me in insert mode"?
  :layout:evil:change-dwim                   #'evil-change
  :layout:evil:change-line-point-to-end      #'evil-change-line

  ;; ┌──────────────────────────────┐
  ;; ├ Indent/Outdent               ┤
  ;; └──────────────────────────────┘
  :layout:evil:text-shift-left               #'evil-shift-left
  :layout:evil:text-shift-right              #'evil-shift-right
  :layout:evil:indent                        #'evil-indent

  ;; ┌──────────────────────────────┐
  ;; ├ Upper/Lower Case             ┤
  ;; └──────────────────────────────┘
  :layout:evil:case-invert                   #'evil-invert-char

  ;; ┌──────────────────────────────┐
  ;; ├ Replace                      ┤
  ;; └──────────────────────────────┘
  :layout:evil:replace-repeat                #'evil-ex-repeat-substitute  ;; Same as: :layout:evil:s//~/
  ;; `evil-replace' is mapped when ':emacs/undo' is /not/ enabled.
  :layout:evil:char-replace                  #'evil-replace

  ;; ┌──────────────────────────────┐
  ;; ├ Line-Based                   ┤
  ;; └──────────────────────────────┘
  :layout:evil:line-join-next-to-current     #'evil-join

  ;; ┌──────────────────────────────┐
  ;; ├ Macros (not Emacs macros)    ┤
  ;; └──────────────────────────────┘
  :layout:evil:macro-record                  #'evil-record-macro
  :layout:evil:macro-execute                 #'evil-execute-macro

  ;; ┌──────────────────────────────┐
  ;; ├ Repeat                       ┤
  ;; └──────────────────────────────┘
  :layout:evil:edit-repeat                   #'evil-repeat)


(input:keyboard/layout:define/keywords :evil
  "┌─────────────────────────────────────────────────────────────────────────┐
   │ Commands                                                                │
   └─────────────────────────────────────────────────────────────────────────┘"
  ;; ┌──────────────────────────────┐
  ;; ├ Evil Command                 ┤
  ;; └──────────────────────────────┘
  :layout:evil:evil-command                  #'evil-ex

  ;; ┌──────────────────────────────┐
  ;; ├ Shell Command                ┤
  ;; └──────────────────────────────┘
  :layout:evil:shell-command                 #'evil-shell-command ;; Execute region as shell command?

  ;; ┌──────────────────────────────┐
  ;; ├ Evil States                  ┤
  ;; └──────────────────────────────┘
  :layout:evil:state-insert-before           #'evil-insert
  :layout:evil:state-insert-after            #'evil-append
  :layout:evil:state-insert-line-start       #'evil-insert-line
  :layout:evil:state-insert-line-end         #'evil-append-line
  :layout:evil:state-insert-line-open-below  #'evil-open-below
  :layout:evil:state-insert-line-open-above  #'evil-open-above
  :layout:evil:state-replace                 #'evil-replace-state
  :layout:evil:state-visual-char-wise        #'evil-visual-char
  :layout:evil:state-visual-line-wise        #'evil-visual-line

  ;; ┌──────────────────────────────┐
  ;; ├ Doom!                        ┤
  ;; └──────────────────────────────┘
  :layout:evil:docs-lookup                   #'+lookup/documentation
  )

;; TODO: HERE YOU ARE- MH, YES.
;;       - Finish the rest:
;;  ;;------------------------------
;;  ;; TODO: All the multi-key keybinds
;;  ;;------------------------------
;;  ;; These aren't keybinds - they just have a lot of keybinds in them.
;;  ;; (:menu-prev  . #'"[")
;;  ;; (:menu-next  . #'"]")
;;  ;; (:menu-text? . #'"g")
;;  ;; (:menu-???   . #'"z")
;;  ;; (:menu-???   . #'"Z")

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
