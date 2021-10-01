;;; config/code/config.el -*- lexical-binding: t; -*-


(imp:require :modules 'spy 'hook 'def)
(imp:require :jerky)


;;------------------------------
;; NOTE:
;;----------
;; 1) Set up some vars, defaults.
;; 2) Call out to other files to set up other modes.
;;    - Base 'prog-mode' should be set up first.
;;------------------------------


;;------------------------------------------------------------------------------
;; General
;;------------------------------------------------------------------------------

(jerky/set 'code 'tab 'normal
           :namespace :default
           :value 4
           :docstr "Default/normal tab width is 4 spaces.")

(jerky/set 'code 'tab 'short
           :namespace :default
           :value 2
           :docstr "Short tab width is 2 spaces.")


;; Use spaces instead of tabs.
;; NOTE: Already set to nil.
;; (setq indent-tabs-mode nil)


;;------------------------------------------------------------------------------
;; Diff
;;------------------------------------------------------------------------------

;;---
;; Set ediff to be nicer...
;;---
;; Defaults to "-w" (ignore whitespace).
;; Don't ignore nothing.
(setq ediff-diff-options "")
;; Always one frame.
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
;; 'Unified'(?) instead of 'copied' context? IDK...
(setq ediff-custom-diff-options "-u")
;; Side-by-side instead of default top/bottom split.
(setq ediff-split-window-function 'split-window-horizontally)


;;------------------------------------------------------------------------------
;; Auto-Formatting
;;------------------------------------------------------------------------------

;; TODO: Change into a func call so various mode configs can do it themselves?

;; Update doom's presets for :format/+onsave's enabled modes.
(setq +format-on-save-enabled-modes
      ;; Starting with `not' inverts this list's meaning to "everything except:"
      '(not emacs-lisp-mode  ; elisp's mechanisms are good enough
            sql-mode         ; sqlformat is currently broken
            tex-mode         ; latexindent is broken
            latex-mode
            python-mode      ; Don't even want to know what this would do if it has one.
            csharp-mode))    ; TODO: Should I enable for this?


;;------------------------------------------------------------------------------
;; Comments
;;------------------------------------------------------------------------------

;; TODO: Should be in keybinds?
;; TODO: Unmap both as `g c' works good?

;; Comment/Uncomment
;; C-x C-; is super awkward on dvorak w/ CAPS-as-ctrl...
;; The evil way:
;;   gc -> start a commenting thing...
;;   gsj -> choose from upcoming line based on letters assigned.
;; or
;;   Vttgc -> Visual mode (V), two lines forward (tt), comment region (gc)
;;   Ctrl+SPC ttgc -> Visual mode (Ctrl+SPC), two lines forward (tt), comment region (gc)
;; or probably a lot of other ones.
(map!
 ;; Unmap the one I don't want.
 "C-x C-;" nil

 ;; "C-/" was 'undo, but I'm used to "C-S--" aka "C-_"
 :desc "Comment/Uncomment" "C-/" #'evilnc-comment-or-uncomment-lines)


;;------------------------------
;; Block Commenting Style
;;------------------------------

;; Only use for languages that have ending comments, like C's /* */.
(spy:hook/defun unused-arg
    '(:name "align-block-commenting"
      :file ".doom.d/config/code.el"
      :docstr "Set comment style for start/end line comment languages (C, HTML, ...)."
      :quiet t)

    ;; `aligned' is like (default) `indent' but also aligns end-of-line comment chars if the language has them.
    (setq 'comment-style 'aligned))

;;---
;; Add hook to languages that need it.
;;---

;; `html-mode-hook' (HTML mode) or `mhtml-mode-hook' (HTML+ mode (derived from HTML mode))?
(add-hook 'html-mode-hook 'sss:hook/align-block-commenting)

;; C-mode hook added (or not) in "+c-and-cpp.el".


;;------------------------------------------------------------------------------
;; Defaults for All Programming Modes
;;------------------------------------------------------------------------------

(spy:hook/defun-and-hooker prog-mode-hook
    '(:name "prog-mode/settings"
      :file ".doom.d/config/code.el"
      :docstr "Settings for all prog-mode derived modes. Non-LSP stuff."
      :quiet t)

    ;; My 2560x1440 monitor can display around 152 columns when fullscreen with
    ;; two vertically-split windows, so we'll do 140 as our fill column?
    (setq fill-column 140))




;;------------------------------------------------------------------------------
;; Metasyntatic Variables
;;------------------------------------------------------------------------------
(setq spy/code/variables.metasyntatic
      '((:metasyntactic (foo (bar (baz (qux (quux (quuux (quuuux (quuuuux))))))
                                  (thud (grunt))
                                  (bletch)
                                  (fum)
                                  (bongo)
                                  (zot)))
         (bazola (ztesch))
         (fred (jim (sheila (barney))))
         (corge (grault (flarp)))
         (zxc (spqr (wombat)))
         (shme)
         (spam (eggs))
         (snork)
         (blarg (wibble))
         (toto (titi (tata (tutu))))
         (pippo (pluto (paperino)))
         (aap (noot (mies)))
         (oogle (foogle (boogle (zork (gork (bork)))))))
        (:pinky (narf (zort (poit (egad (troz (fiddely-posh)))))))))


;; TODO: This?
;; (defun spy/code/var ()
;;   "Returns a metasyntatic variable and copies it into the kill ring."
;;   (interactive)
;;   ;; TODO: this?
;;   )


;;------------------------------------------------------------------------------
;; Programming Mode Configs
;;------------------------------------------------------------------------------

(load! "+c-and-cpp")
(load! "+python")
