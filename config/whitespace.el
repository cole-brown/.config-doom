;;; cconfig/whitespace.el -*- lexical-binding: t; -*-


(imp:require :modules 'spy 'hook 'def)


;;------------------------------------------------------------------------------
;; Whitespace Butler
;;------------------------------------------------------------------------------

;; Already provided by Doom - Just need to set a thing or two.
(after! ws-butler
  ;; Convert leading whitespace.
  (customize-set-variable 'ws-butler-convert-leading-tabs-or-spaces t)

  ;;------------------------------
  ;; "Losing a Space on Save" Bug?
  ;;------------------------------
  ;; Are we losing a space in Doom/emacs-27.1 like I was in emacs-26.3 vanilla?
  ;; Haven't noticed any yet. If so, this was my fix:
  ;;---
  ;; (defun spydez/advice/move-to-column/force-fix (args)
  ;;   "Un-lose the one single space that's being lost sometimes."
  ;;   (let ((column (nth 0 args))
  ;;         (force (nth 1 args)))
  ;;
  ;;     ;; bug conditions:
  ;;     ;;   1. whitespace-mode is on
  ;;     ;;   2. move-to-column is called with 'force' set true.
  ;;     ;;   3. ws-butler-keep-whitespace-before-point is on
  ;;     ;; Number 3 isn't actually necessary but it's the only time I've
  ;;     ;; noticed this bug (aside from contriving it in bug hunts/repros).
  ;;     (when (and (or global-whitespace-mode whitespace-mode)
  ;;                force
  ;;                ;; Not needed but ws-butler is what triggers this all the time
  ;;                ;; so I'll contain my brute force fix to only work if ws-butler
  ;;                ;; is setup to expect move-to-column to restore point.
  ;;                ws-butler-keep-whitespace-before-point)
  ;;       ;; Possibly a bugged move-to-column... Let's figure out how far we
  ;;       ;; have to go.
  ;;       (save-excursion
  ;;         (let ((at-last-line (> (forward-line 1) 0)))
  ;;           (unless at-last-line (forward-line -1))
  ;;           (move-end-of-line nil)
  ;;           (when (and (> column (current-column))
  ;;                      (not at-last-line))
  ;;             ;; We're in bug territory, and we want past current EOL, and this
  ;;             ;; line has a '\n' in it, so I think we have a bugged
  ;;             ;; move-to-column case. Up by one to offset for move-to-column's
  ;;             ;; off-by-one-in-this-instance bug.
  ;;             (setq column (1+ column))))))
  ;;     ;; return list of (fixed or ignored) inputs
  ;;     (list column force)))
  ;; ;; And now add our shenanigan to the function...
  ;; (advice-add 'move-to-column
  ;;             :filter-args #'spydez/advice/move-to-column/force-fix
  ;;            )
  ;;---
  )


;;------------------------------------------------------------------------------
;; Whitespace-Mode
;;------------------------------------------------------------------------------

(defvar sss:whitespace-mode:style
  ;;---
  ;; visualization via faces (see set-face-attribute below)
  ;;---
  '(face

    ;;---
    ;; general/normal whitespace
    ;;---
    tabs spaces newline

    ;;---
    ;; the bad kind
    ;;---
    trailing space-before-tab space-after-tab

    ;; Emacs 26.3:
    ;; `empty' lines were annoying as emacs or whitespace is bad at cleaning up
    ;; the visualization when the line is no longer matching this whitespace
    ;; warning type.
    ;; NOTE: Have not tested in emacs 27+.
    ;;empty       ;; ...lines (...at beginning/end of buffer)

    lines-tail  ;; `lines' would be whole line...
    ;; lines-tail is just whatever's past fill-column

    ;;---
    ;; not sure if want or bad or what.
    ;;---
    indentation

    ;;---
    ;; visualize these whitespaces with non-whitespace chars via display-table
    ;;---
    space-mark tab-mark newline-mark)
  "Desired whitespace-style setting.
Will this get rid of the whitspace-mode/org-mode hook bug with `lines-tail'?
Find out next time...")


(use-package! whitespace
  ;;------------------------------
  :init
  ;;------------------------------

  ;; An org-mode/whitespace-mode hooks.
  (spy:hook/defun org-mode-hook
    '(:name "org/whitespace-mode"
      :file ".doom.d/config/whitespace.el"
      :docstr "I like some whitespace-mode stuff in org-mode, but want less than other modes."
      :quiet t)
    ;; make a local copy of whitespace-style we can modify and...
    (set (make-local-variable 'whitespace-style)
         ;; ...set it as old one with removed 'too-long line' highlighting
         (remove 'lines-tail sss:whitespace-mode:style)))


  ;;------------------------------
  :hook
  ;;------------------------------

  ;; Connect my hooks up.
  (org-mode . sss:hook/org/whitespace-mode)


  ;;------------------------------
  :config
  ;;------------------------------

  ;; Doom already does this.
  ;; (customize-set-variable 'whitespace-line-column nil
  ;;  (concat "Set 'lines-tail/'lines in `whitespace-style' to base "
  ;;          "off of `fill-column' instead of just 80."))

  ;;---
  ;; Whitespace Style
  ;;---

  ;; Doom has this reduced down to: '(face tabs tab-mark)
  ;; I want to see the good /and/ the bad whitespace.
  (customize-set-variable 'whitespace-style
                          sss:whitespace-mode:style)
  ;; whitespace-style

  ;;---
  ;; Whitespace Faces
  ;;---
  ;; Tweaks to theme faces done in config/theme/<name>.el

  ;;---
  ;; Enable Globally all the time.
  ;;---
  ;; positive: enable, other: disable
  (global-whitespace-mode +1))
