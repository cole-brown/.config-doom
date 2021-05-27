;;; config/code.el -*- lexical-binding: t; -*-


(spy:require :spy 'hook 'def)
(spy:require :spy 'jerky)


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

;; Update doom's presets for :format/+onsave's enabled modes.
(setq +format-on-save-enabled-modes
      ;; Starting with `not' inverts this list's meaning to "everything except:"
      '(not emacs-lisp-mode  ; elisp's mechanisms are good enough
            sql-mode         ; sqlformat is currently broken
            tex-mode         ; latexindent is broken
            latex-mode
            python-mode      ; Don't even want to know what this would do if it has one.
            csharp-mode))    ; Work has its own formatting style.


;;------------------------------------------------------------------------------
;; Comments
;;------------------------------------------------------------------------------

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


;;------------------------------------------------------------------------------
;; Python
;;------------------------------------------------------------------------------

(use-package! python

  ;;-----
  :config
  ;;-----

  (customize-set-variable 'python-indent-offset
                          (jerky/get 'code 'tab 'normal)
                          "Set indent to tab-width.")

  (customize-set-variable 'python-fill-docstring-style
                          'symmetric)

  ;; Create and add my python-mode hook function to python-mode's hook var.
  (spy:hook/defun-and-hooker python-mode-hook
    '(:name "python/settings"
      :file ".doom.d/config/code.el"
      :docstr "Settings for python-mode itself. Non-LSP stuff."
      :quiet t)

    ;; pycodestyle insists 79 is the One True Fill Column...
    ;; We'll try it for all our python in general.
    (setq fill-column 79))
  )


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
