;;; config/code.el -*- lexical-binding: t; -*-


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
;; Comments
;;------------------------------------------------------------------------------

;; Comment/Uncomment
;; C-x C-; is super awkward on dvorak w/ CAPS-as-ctrl...
(map!
 ;; Unmap the one I don't want.
 "C-x C-;" nil

 ;; "C-/" was 'undo, but I'm used to "C-S--" aka "C-_"
 :desc "Comment/Uncomment" "C-/" #'evilnc-comment-or-uncomment-lines)
