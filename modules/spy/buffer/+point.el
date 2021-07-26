;;; spy/buffer/point.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Point Utils - Checking Out Things About Point
;;------------------------------------------------------------------------------

;; http://ergoemacs.org/emacs/elisp_determine_cursor_inside_string_or_comment.html
(defun spy:point/inside-string-p ()
  "Returns non-nil if inside string, else nil.
Result depends on syntax table's string quote character."
  (let ((result (nth 3 (syntax-ppss))))
    result))

;; http://ergoemacs.org/emacs/elisp_determine_cursor_inside_string_or_comment.html
(defun spy:point/inside-comment-p ()
  "Returns non-nil if inside comment, else nil.
Result depends on syntax table's comment character."
  (let ((result (nth 4 (syntax-ppss))))
    result))

;; https://emacs.stackexchange.com/questions/16792/easiest-way-to-check-if-current-line-is-empty-ignoring-whitespace
(defun spy:point/current-line-empty-p ()
  (save-excursion
    (beginning-of-line)
    (looking-at "[[:space:]]*$")))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'buffer 'point)
