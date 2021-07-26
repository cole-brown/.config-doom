;;; spy/buffer/line.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Rebind to Smarter Functions:
;;------------------------------------------------------------------------------

;; ;; remap C-a to `smarter-move-beginning-of-line'
;; (bind-key [remap move-beginning-of-line]
;;           'spy:smarter-move-beginning-of-line)
;;
;;
;; ;; remap C-a to `smarter-beginning-of-visual-line' in visual-line-mode-map
;; (bind-keys :map visual-line-mode-map
;;            ;; beginning of line
;;            ([remap beginning-of-visual-line]
;;             . spy:smarter-beginning-of-visual-line)
;;            ([remap move-beginning-of-line]
;;             . spy:smarter-beginning-of-visual-line)
;;            ;; end of line
;;            ([remap end-of-visual-line]
;;             . spy:smarter-end-of-visual-line)
;;            ([remap move-end-of-line]
;;             . spy:smarter-end-of-visual-line))


;;------------------------------------------------------------------------------
;; Lines
;;------------------------------------------------------------------------------
;; What is "the 'beginning' of the 'line'" anyways?

;;---
;; Logical Lines
;;---

;; https://emacsredux.com/blog/2013/05/22/smarter-navigation-to-the-beginning-of-a-line/
;; Trial 1 [2019-01-29]: Use code from link.
;; Trial 2 [2019-05-17]: Do beginning of line first, not second.
;; TRIAL END [2020-02-03]: Trial successful; keep this.
(defun spy:cmd:smarter-move-beginning-of-line (arg)
  "Move point to beginning of line, or indentation.

Move point to the beginning of the line. If point is already
there, move to the first non-whitespace character on this line.
Effectively toggle between the beginning of the line and the
first non-whitespace character.

If ARG is not nil or 1, move forward ARG - 1 lines first.  If
point reaches the beginning or end of the buffer, stop there.
"
  (interactive "^p")
  (setq arg (or arg 1))

  ;; Move lines first
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))

  ;; Wasn't liking C-a having unexpected effects. Was originally:
  ;;   1) Go to first non-whitespace.
  ;;   2) Else go to beginning of line.
  ;; I've reversed those so one C-a works how my fingers expect but spamming
  ;; is useful to remind me of the new functionality.
  (let ((orig-point (point)))
    (move-beginning-of-line 1)
    ;; If that did nothing, jump to indentation.
    (when (= orig-point (point))
      (back-to-indentation))))



;;---
;; Visual Lines
;;---

(defun spy:cmd:smarter-beginning-of-visual-line (arg)
  "Move point to beginning of visual line, or actual line, or indentation.

Move point to the beginning of the (visual) line. If point is
already there, move point to the beginning of the (actual/logical) line.
If point is already there, move to the first non-whitespace
character on this line. Effectively toggle between the beginning
of the visual line, logical line, and the first non-whitespace
character.

If ARG is not nil or 1, move forward ARG - 1 lines first.  If
point reaches the beginning or end of the buffer, stop there.
"
  (interactive "^p")
  (setq arg (or arg 1))

  ;; Move lines first
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))

  ;; Move in the line now.
  (let ((orig-point (point)))
    (beginning-of-visual-line 1)
    ;; If that did nothing, jump into `spy:cmd:smarter-move-beginning-of-line'
    ;; for more beginnings.
    (when (= orig-point (point))
      (spy:cmd:smarter-move-beginning-of-line 1))))


(defun spy:cmd:smarter-end-of-visual-line (arg)
  "Move point to end of visual line, or actual line.

Move point to the end of the (visual) line. If point is already
there, move point to the end of the (actual/logical) line.
Effectively toggle between the end of the visual line and
logical line.

If ARG is not nil or 1, move forward ARG - 1 lines first.  If
point reaches the beginning or end of the buffer, stop there.
"
  (interactive "^p")
  (setq arg (or arg 1))

  ;; Move lines first
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))

  ;; Move in the line now.
  (let ((orig-point (point)))
    (end-of-visual-line 1)
    ;; If that did nothing, jump to end of actual/logical line.
    (when (= orig-point (point))
      (move-end-of-line 1))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'buffer 'line)
