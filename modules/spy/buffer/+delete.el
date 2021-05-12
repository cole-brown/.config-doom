;;; spy/buffer/+delete.el -*- lexical-binding: t; -*-



(defun sss:buffer/delete.word (arg)
  "Avoids kill ring. Kill characters forward until encountering
the end of a word. Delete ARG number of words.
"
  (delete-region (point) (progn (forward-word arg) (point))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(spy:provide :spy 'buffer 'delete)
